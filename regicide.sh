#!/bin/bash

# --- Formatting & Colors ---
RED='\033[0;31m'; BLUE='\033[0;34m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'

# --- Value Parser ---
get_val() {
    local v=$1
    case $v in
        A) echo 1 ;;
        J) echo 10 ;;
        Q) echo 15 ;;
        K) echo 20 ;;
        *) echo $v ;;
    esac
}

# --- The Grimoire of Lost Souls ---
show_help() {
    echo -e "\n${YELLOW}${BOLD}--- THE GRIMOIRE OF LOST SOULS ---${NC}"
    echo -e "You stand in a land where the royalty has been twisted by a dark, oily shadow."
    echo -e "${BOLD}THE SACRED LAWS OF COMBAT:${NC}"
    echo -e "  - ${GREEN}Clubs:${NC} Double the strike's potency ${BOLD}BEFORE${NC} other elements trigger."
    echo -e "  - ${RED}Hearts:${NC} Mend the Tavern (Discard pile returns to Draw deck)."
    echo -e "  - ${YELLOW}Diamonds:${NC} Sift through the Tavern to find new weapons."
    echo -e "  - ${BLUE}Spades:${NC} Forge an Aegis to parry the coming blow."
    echo -e "  - ${BOLD}Ace Link:${NC} An Ace linked to a card doubles its elemental reach."
    echo -e "  - ${BOLD}Combos:${NC} Multiple cards of one rank (sum <= 10) combine their power."
    echo -e "----------------------------------"
}

# --- Narrative Logic ---
describe_room() {
    local rank=$1
    echo ""
    case $rank in
        J) echo -e "${BLUE}The iron doors groan. You have entered the ${BOLD}Sunken Dungeons${NC}."
           echo "Water drips from the ceiling with a rhythmic 'plip-plip'. A shadow detaches itself from the wall..." ;;
        Q) echo -e "${YELLOW}The scent of stale perfume and blood fills the air. You are in the ${BOLD}Great Throne Room${NC}."
           echo "Dust motes dance in shafts of moonlight. A figure in tattered silk stands before a cracked mirror..." ;;
        K) echo -e "${RED}Reality is thin here. You have entered the ${BOLD}Inner Sanctum of the Void${NC}."
           echo "The floor feels like obsidian. A towering presence waits, its eyes burning like dying stars..." ;;
    esac
}

# --- Setup ---
draw_deck=(); discard_pile=(); player_hand=(); castle_deck=()
suits=("H" "D" "S" "C")

for s in "${suits[@]}"; do
    for v in {2..10} A; do draw_deck+=("${v}${s}"); done
done
draw_deck+=("Joker1" "Joker2")
draw_deck=($(shuf -e "${draw_deck[@]}"))

for rank in K Q J; do
    group=(); for s in "${suits[@]}"; do group+=("${rank}${s}"); done
    shuffled_group=($(shuf -e "${group[@]}"))
    castle_deck+=("${shuffled_group[@]}")
done

for i in {1..8}; do player_hand+=("${draw_deck[0]}"); draw_deck=("${draw_deck[@]:1}"); done

shield=0; boss_suit_active=true; last_captured=""

echo -e "${BOLD}West of House.${NC}"
echo -e "You are standing in an open field west of a white house, with a boarded front door."
echo -e "Wait, no. You are standing at the ${YELLOW}${BOLD}CORRUPTED KEEP${NC}."
echo -e "Your pouch feels heavy with 8 cards. Darkness awaits."

# ------------------ ENGINE ------------------
while [ ${#castle_deck[@]} -gt 0 ]; do
    current_boss=${castle_deck[-1]}
    [[ $boss_suit_active == true ]] && active_suit=${current_boss: -1} || active_suit="NONE"
    boss_rank=${current_boss:0:1}

    case $boss_rank in 
        J) b_name="Jack"; b_max=20; b_a=10 ;; 
        Q) b_name="Queen"; b_max=40; b_a=15 ;; 
        K) b_name="King"; b_max=60; b_a=20 ;; 
    esac

    if [[ -z $boss_hp ]]; then
        describe_room "$boss_rank"
        echo -e "A ${RED}${b_name} of ${current_boss: -1}${NC} challenges your passage!"
        boss_hp=$b_max
    fi

    echo -e "\n${BOLD}[$b_name Status]${NC} HP: ${RED}${boss_hp}${NC} | ATK: ${RED}${b_a}${NC} | Shield: ${BLUE}${shield}${NC}"
    echo -e "${BOLD}[Your Pouch]${NC} ${player_hand[@]} (${#draw_deck[@]} in Tavern)"
    
    read -p "What do you want to do? > " move
    if [[ $move == "help" || $move == "h" ]]; then show_help; continue; fi
    if [[ $move == "save" ]]; then
        echo "${draw_deck[@]}|${discard_pile[@]}|${player_hand[@]}|${castle_deck[@]}|$boss_hp|$shield" > regicide_save.txt
        echo "You carefully inscribe the details of your journey into your journal."; continue
    fi
    if [[ $move == "load" && -f regicide_save.txt ]]; then
        IFS='|' read -r d_d d_p p_h c_d b_h s_h < regicide_save.txt
        draw_deck=($d_d); discard_pile=($d_p); player_hand=($p_h); castle_deck=($c_d); boss_hp=$b_h; shield=$s_h
        echo "The world blurs as memories of the past become your present."; continue
    fi

    if [[ $move == "Joker"* ]]; then
        if [[ ! " ${player_hand[@]} " =~ "$move" ]]; then echo "You search your pouch but find no Joker."; continue; fi
        echo -e "\n${YELLOW}You unleash a Joker! A flash of chaotic light blinds the ${b_name}.${NC}"
        boss_suit_active=false
        for c in "${player_hand[@]}"; do [[ $c != "$move" ]] && draw_deck+=("$c"); done
        player_hand=(); for i in {1..8}; do [[ ${#draw_deck[@]} -gt 0 ]] && player_hand+=("${draw_deck[0]}") && draw_deck=("${draw_deck[@]:1}"); done
        continue
    fi

    cards=($move); base_sum=0; suits_to_trigger=(); valid_play=true; first_rank=""
    for c in "${cards[@]}"; do
        if [[ ! " ${player_hand[@]} " =~ " $c " ]]; then valid_play=false; break; fi
        v="${c%?}"; s="${c: -1}"; n=$(get_val "$v")
        if [[ "$v" != "A" ]]; then
            if [[ -z "$first_rank" ]]; then first_rank="$v"
            elif [[ "$first_rank" != "$v" ]]; then valid_play=false; break; fi
        fi
        base_sum=$((base_sum + n)); suits_to_trigger+=("$s")
    done
    
    has_ace=false; for c in "${cards[@]}"; do [[ "${c%?}" == "A" ]] && has_ace=true; done
    if [[ "$has_ace" == false && ${#cards[@]} -gt 1 && $base_sum -gt 10 ]]; then
        echo "That combo is too unstable for your hands! (Max 10)."; continue
    fi
    [[ "$valid_play" == false ]] && { echo "That action is not possible here."; continue; }

    # Discard
    for c in "${cards[@]}"; do player_hand=(${player_hand[@]/$c/}); discard_pile+=("$c"); done

    # --- THE POWER UP PHASE ---
    power_val=$base_sum
    club_active=false
    for s in "${suits_to_trigger[@]}"; do
        if [[ "$s" == "C" && "$active_suit" != "C" ]]; then club_active=true; fi
    done
    [[ $club_active == true ]] && power_val=$((base_sum * 2))

    boss_hp=$((boss_hp - power_val))
    echo -e "\nYou strike the ${b_name} for ${power_val} damage!"

    # Capture logic
    if [ $boss_hp -eq 0 ]; then
        draw_deck=("$current_boss" "${draw_deck[@]}"); last_captured="$current_boss"
    fi

    # Trigger Powers using power_val
    for s in "${suits_to_trigger[@]}"; do
        if [[ "$s" != "$active_suit" ]]; then
            case $s in
                C) echo -e "${GREEN}The energy of Clubs surges. The strike's potency is doubled to ${power_val}!${NC}" ;;
                S) shield=$((shield + power_val)); echo -e "${BLUE}The Spades form a magical Aegis, shielding you for ${power_val}.${NC}" ;;
                H) take=$power_val; shuffled_discard=($(shuf -e "${discard_pile[@]}"))
                   [[ $take -gt ${#shuffled_discard[@]} ]] && take=${#shuffled_discard[@]}
                   for ((i=0; i<take; i++)); do draw_deck+=("${shuffled_discard[$i]}"); discard_pile=(${discard_pile[@]/${shuffled_discard[$i]}}); done
                   echo -e "${RED}The Hearts beat with warmth. ${take} souls return to the Tavern.${NC}" ;;
                D) d_count=0; for ((i=0; i<power_val; i++)); do
                     if [[ ${#draw_deck[@]} -gt 0 && ${#player_hand[@]} -lt 8 ]]; then
                        new_card="${draw_deck[0]}"
                        if [[ "$new_card" == "$last_captured" ]]; then echo -e "${YELLOW}*** You reach into the Tavern and find the purified ${new_card}! ***${NC}"; last_captured=""; fi
                        player_hand+=("$new_card"); draw_deck=("${draw_deck[@]:1}"); ((d_count++))
                     fi
                   done
                   echo -e "${YELLOW}Diamonds glint. You draw ${d_count} new weapons into your pouch.${NC}" ;;
            esac
        else echo -e "The ${b_name} sneers; your elemental ${s} power is useless here."; fi
    done

    if [ $boss_hp -le 0 ]; then
        echo -e "${GREEN}${BOLD}The ${b_name} collapses!${NC}"
        [[ $boss_hp -lt 0 ]] && echo "The blow was too powerful. The royal's soul is shattered." && discard_pile+=("$current_boss")
        [[ $boss_hp -eq 0 ]] && echo "The strike was precise. The royal's spirit is cleansed."
        unset boss_hp; shield=0; boss_suit_active=true; unset castle_deck[-1]; continue
    fi

    # Counter-attack
    eff_atk=$((b_a - shield)); [[ $eff_atk -lt 0 ]] && eff_atk=0
    echo -e "\nThe ${b_name} recovers and prepares a counter-attack for ${RED}${eff_atk}${NC} damage!"
    
    while [ $eff_atk -gt 0 ]; do
        [[ ${#player_hand[@]} -eq 0 ]] && echo -e "${RED}You have been eaten by a grue. Your journey ends here.${NC}" && exit
        echo -e "${BOLD}[Current Pouch]${NC} ${player_hand[@]}"
        echo -ne "What will you sacrifice to survive? (Need $eff_atk more): "
        read -a dcards
        for dc in "${dcards[@]}"; do
            if [[ " ${player_hand[@]} " =~ " $dc " ]]; then
                dv="${dc%?}"; dn=$(get_val "$dv")
                eff_atk=$((eff_atk - dn)); player_hand=(${player_hand[@]/$dc/}); discard_pile+=("$dc")
                echo "You cast aside the $dc. (Remaining: $(( eff_atk > 0 ? eff_atk : 0 )))"
            else
                echo -e "${RED}You search your pouch for $dc, but find only dust.${NC}"
            fi
        done
    done
    echo "The dust settles. You are still standing."
done
echo -e "\n${YELLOW}${BOLD}The Keep falls silent. The corruption is purged. You have won!${NC}"


