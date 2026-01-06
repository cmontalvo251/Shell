#!/bin/bash

# --- Formatting ---
RED='\033[0;31m'; BLUE='\033[0;34m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'

# --- Help Function ---
show_help() {
    clear
    echo -e "${YELLOW}${BOLD}=== REGICIDE COMMAND MANUAL ===${NC}"
    echo -e "${BOLD}Objective:${NC} Defeat 12 Bosses (4 Jacks, 4 Queens, 4 Kings)."
    echo ""
    echo -e "${BOLD}Suit Powers:${NC}"
    echo -e " ${RED}Hearts (H):${NC} Refill Draw Deck from Discard pile."
    echo -e " ${YELLOW}Diamonds (D):${NC} Draw cards to your hand."
    echo -e " ${BLUE}Spades (S):${NC} Reduce the Boss's attack power."
    echo -e " ${BOLD}Clubs (C):${NC} Deal Double Damage."
    echo ""
    echo -e "${BOLD}Special Moves:${NC}"
    echo -e " - ${BOLD}Combos:${NC} Play multiple cards of the SAME number (e.g., '2H 2S'). Total must be <= 10."
    echo -e " - ${BOLD}Ace Link:${NC} Play 1 Ace with 1 other card (e.g., 'AS 10C'). Triggers BOTH suits!"
    echo -e " - ${BOLD}Joker:${NC} Reset immunity, skip boss attack, and draw a new hand."
    echo -e " - ${BOLD}Capture:${NC} Hit a boss for EXACTLY their remaining HP to put them on top of your deck."
    echo ""
    echo -e "Press any key to return to the battle..."
    read -n 1
}

# --- Setup Decks ---
draw_deck=(); discard_pile=(); player_hand=(); castle_deck=()
suits=("H" "D" "S" "C")

for s in "${suits[@]}"; do
    for v in {2..10} A; do draw_deck+=("${v}${s}"); done
done
draw_deck+=("Joker1" "Joker2")
draw_deck=($(shuf -e "${draw_deck[@]}"))

for rank in K Q J; do
    group=()
    for s in "${suits[@]}"; do group+=("${rank}${s}"); done
    shuffled_group=($(shuf -e "${group[@]}"))
    castle_deck+=("${shuffled_group[@]}")
done

for i in {1..8}; do player_hand+=("${draw_deck[0]}"); draw_deck=("${draw_deck[@]:1}"); done

shield=0
boss_suit_active=true

# ------------------ GAME ENGINE ------------------
while [ ${#castle_deck[@]} -gt 0 ]; do
    current_boss=${castle_deck[-1]}
    [[ $boss_suit_active == true ]] && active_suit=${current_boss: -1} || active_suit="NONE"
    boss_rank=${current_boss:0:1}

    case $boss_rank in J) b_max=20; b_a=10 ;; Q) b_max=40; b_a=15 ;; K) b_max=60; b_a=20 ;; esac
    [[ -z $boss_hp ]] && boss_hp=$b_max

    clear
    echo -e "${YELLOW}=== REGICIDE: ULTIMATE EDITION ===${NC}"
    echo -e "Boss: ${BOLD}${current_boss}${NC} (Immunity: ${RED}${active_suit}${NC}) | HP: ${RED}${boss_hp}${NC} | ATK: ${RED}${b_a}${NC}"
    echo -e "Shield: ${BLUE}${shield}${NC} | Deck: ${#draw_deck[@]} | Discard: ${#discard_pile[@]}"
    echo "------------------------------------------"
    echo -e "Your Hand: ${player_hand[@]}"
    echo "------------------------------------------"
    read -p "Enter card(s), 'help', or 'Joker': " move

    # Check for Help
    if [[ $move == "help" || $move == "h" ]]; then show_help; continue; fi

    # Joker Handler
    if [[ $move == "Joker"* ]]; then
        if [[ ! " ${player_hand[@]} " =~ "$move" ]]; then echo "No Joker!"; sleep 1; continue; fi
        boss_suit_active=false
        for c in "${player_hand[@]}"; do [[ $c != "$move" ]] && draw_deck+=("$c"); done
        player_hand=(); player_hand=(${player_hand[@]/$move/})
        for i in {1..8}; do [[ ${#draw_deck[@]} -gt 0 ]] && player_hand+=("${draw_deck[0]}") && draw_deck=("${draw_deck[@]:1}"); done
        echo "Joker: Hand reset, Immunity cleared!"; sleep 2; continue
    fi

    # --- Combo & Ace Link Validation ---
    cards=($move)
    total_num=0; suits_to_trigger=(); first_val=""
    is_ace_link=false; valid_play=true

    for c in "${cards[@]}"; do
        if [[ ! " ${player_hand[@]} " =~ " $c " ]]; then valid_play=false; break; fi
        v="${c%?}"; s="${c: -1}"
        [[ $v == "A" ]] && n=1 || n=$v
        total_num=$((total_num + n))
        suits_to_trigger+=("$s")
        
        if [ -z "$first_val" ]; then first_val=$v; fi
        if [ "$v" == "A" ]; then is_ace_link=true; fi
        if [ ${#cards[@]} -gt 1 ] && [ "$v" != "$first_val" ] && [ "$is_ace_link" = false ]; then valid_play=false; fi
    done

    if [ "$is_ace_link" = false ] && [ $total_num -gt 10 ]; then valid_play=false; fi
    if [ "$valid_play" = false ]; then echo -e "${RED}Invalid! Try 'help' for rules.${NC}"; sleep 2; continue; fi

    # --- Execute Powers ---
    dmg=$total_num
    for s in "${suits_to_trigger[@]}"; do
        if [[ "$s" != "$active_suit" ]]; then
            case $s in
                C) dmg=$((total_num * 2)); echo "Clubs: Double Power!" ;;
                S) shield=$((shield + total_num)); echo "Spades: Shield +$total_num" ;;
                H) take=$total_num; shuffled_discard=($(shuf -e "${discard_pile[@]}"))
                   [[ $take -gt ${#shuffled_discard[@]} ]] && take=${#shuffled_discard[@]}
                   for ((i=0; i<take; i++)); do draw_deck+=("${shuffled_discard[$i]}"); discard_pile=(${discard_pile[@]/${shuffled_discard[$i]}}); done
                   echo "Hearts: Healed $take!" ;;
                D) for ((i=0; i<total_num; i++)); do [[ ${#draw_deck[@]} -gt 0 && ${#player_hand[@]} -lt 8 ]] && player_hand+=("${draw_deck[0]}") && draw_deck=("${draw_deck[@]:1}"); done
                   echo "Diamonds: Drew cards!" ;;
            esac
        else echo -e "${RED}Immune to $s power!${NC}"; fi
    done

    # --- Damage & Discard Logic ---
    boss_hp=$((boss_hp - dmg))
    for c in "${cards[@]}"; do player_hand=(${player_hand[@]/$c/}); discard_pile+=("$c"); done

    if [ $boss_hp -le 0 ]; then
        echo -e "${GREEN}BOSS DEFEATED!${NC}"; [[ $boss_hp -eq 0 ]] && draw_deck=("$current_boss" "${draw_deck[@]}") || discard_pile+=("$current_boss")
        unset boss_hp; shield=0; boss_suit_active=true; unset castle_deck[-1]; sleep 2; continue
    fi

    eff_atk=$((b_a - shield)); [[ $eff_atk -lt 0 ]] && eff_atk=0
    echo -e "The Boss strikes for ${RED}$eff_atk${NC} damage!"
    while [ $eff_atk -gt 0 ]; do
        [[ ${#player_hand[@]} -eq 0 ]] && echo -e "${RED}GAME OVER.${NC}" && exit
        read -p "Discard for $eff_atk: " dc
        if [[ " ${player_hand[@]} " =~ " $dc " ]]; then
            dv="${dc%?}"; [[ $dv == "A" ]] && dn=1 || dn=$dv
            eff_atk=$((eff_atk - dn)); player_hand=(${player_hand[@]/$dc/}); discard_pile+=("$dc")
        fi
    done
done
echo "VICTORY!"
