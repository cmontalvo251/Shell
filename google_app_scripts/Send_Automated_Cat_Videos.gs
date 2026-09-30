/**
 * ------------------------------------------------------------------------------------------------
 * SCRIPT INSTRUCTIONS:
 * This Google Apps Script function searches YouTube for the 10 most relevant cat videos 
 * and then sends 10 SEPARATE EMAILS—one for each video link—to the specified receiver.
 * * * SETUP STEPS:
 * 1. Open your Google Sheet, or go directly to script.google.com.
 * 2. Go to Extensions -> Apps Script to open the editor.
 * 3. In the Apps Script editor, you MUST enable the YouTube Data API service. 
 * Click the '+' next to "Services" (in the left menu), find "YouTube Data API," and click Add.
 * 4. Replace "your_email@example.com" in the RECEIVER_EMAIL constant with your actual email.
 * 5. Click the Save icon (floppy disk), then select the function name (emailFirstTenCatVideos) 
 * from the dropdown menu and click Run.
 * 6. You will be prompted to authorize the script to use the YouTube service and send emails.
 * ------------------------------------------------------------------------------------------------
 */

/* If you don't have authorization to login with two factor then you'll need to use the hardcoded version of the URLs.
*/

// --- Configuration ---
const RECEIVER_EMAIL = "your_email@example.com"; // <-- REPLACE THIS
const SEARCH_QUERY = "cute cat videos funny";
const VIDEO_COUNT = 50;
//const MAX_YOUTUBE_RESULTS = 50; 
 
/**
 * Searches YouTube for cat videos and emails the first 10 links individually.
 */
function emailFirstTenCatVideos() {
  
  //Logger.log(`Starting search for ${VIDEO_COUNT} cat videos...`);
  
  // 1. Execute the YouTube search using the built-in Service
  /*const params = {
    q: SEARCH_QUERY,
    part: 'id,snippet',
    type: 'video',
    maxResults: MAX_YOUTUBE_RESULTS, 
    videoEmbeddable: 'true',
    order: 'relevance' 
  };*/
    
  //const searchResponse = YouTube.Search.list('id,snippet',params);
  
  // Extract video IDs and map them to full YouTube URLs, ensuring we take only the top 10
  /*const topTenVideos = searchResponse.items
                                      .filter(item => item.id.videoId)
                                      .map(item => `https://www.youtube.com/watch?v=${item.id.videoId}`)
                                      .slice(0, VIDEO_COUNT);
  */
  const topTenVideos = ['https://www.youtube.com/watch?v=3URtTIdnXIk',
'https://www.youtube.com/watch?v=KId3r5dVwGk',
'https://www.youtube.com/watch?v=cytJLvf-eVs',
'https://www.youtube.com/watch?v=1UgJI6O8T2U',
'https://www.youtube.com/watch?v=GMXGinLmzKs',
'https://www.youtube.com/watch?v=O4poBAr8XSM',
'https://www.youtube.com/watch?v=YDbY9TTjv_w',
'https://www.youtube.com/watch?v=1GDkjZm6coU',
'https://www.youtube.com/watch?v=EM41yq0OUQ4',
'https://www.youtube.com/watch?v=9TKxHUqWAo4',
'https://www.youtube.com/watch?v=6KkYleRgpBQ',
'https://www.youtube.com/watch?v=kN0VtpArNE4',
'https://www.youtube.com/watch?v=xFzLKMJwY3M',
'https://www.youtube.com/watch?v=Po098TRdOn4',
'https://www.youtube.com/watch?v=UPySIokNM_I',
'https://www.youtube.com/watch?v=BfPFkPu4qwc',
'https://www.youtube.com/watch?v=acQKF6mRRqQ',
'https://www.youtube.com/watch?v=ZvrWSP3kTXk',
'https://www.youtube.com/watch?v=3bhkYoMWTFE',
'https://www.youtube.com/watch?v=jGuKdvmwYio',
'https://www.youtube.com/watch?v=-vzQdTvm2VA',
'https://www.youtube.com/watch?v=vQlE0qV6iuQ',
'https://www.youtube.com/watch?v=4z8Hi_uQOkE',
'https://www.youtube.com/watch?v=TUux-r9gAq0',
'https://www.youtube.com/watch?v=NSWihO8N8W8',
'https://www.youtube.com/watch?v=z4OC3pYuOUw',
'https://www.youtube.com/watch?v=_kunFuIuXbM',
'https://www.youtube.com/watch?v=dlicrf-MlbE',
'https://www.youtube.com/watch?v=RFMuw3xpmFE',
'https://www.youtube.com/watch?v=hnqqVCXdNHk',
'https://www.youtube.com/watch?v=YbWETKda1rE',
'https://www.youtube.com/watch?v=c5NfVEL_yBc',
'https://www.youtube.com/watch?v=F3qE951zzqA',
'https://www.youtube.com/watch?v=G_IgFwA5GH4',
'https://www.youtube.com/watch?v=9ZQqPks_APk',
'https://www.youtube.com/watch?v=pIDF-z1PxZo',
'https://www.youtube.com/watch?v=aGZK_AWD_bg',
'https://www.youtube.com/watch?v=wxuY3ctx2J0',
'https://www.youtube.com/watch?v=YYQtJsudPvk',
'https://www.youtube.com/watch?v=d8hB1A1ohRI',
'https://www.youtube.com/watch?v=qvh-agdU0oE',
'https://www.youtube.com/watch?v=7GC-7t7WYqI',
'https://www.youtube.com/watch?v=CY8fg57yTaU',
'https://www.youtube.com/watch?v=y6kwZPbBw8o',
'https://www.youtube.com/watch?v=qDs6GLAWn4w',
'https://www.youtube.com/watch?v=c02UYFG9aRI',
'https://www.youtube.com/watch?v=2TbZMpOKOOM',
'https://www.youtube.com/watch?v=_DHipmCypjs',
'https://www.youtube.com/watch?v=9AjIYRoW7W8',
'https://www.youtube.com/watch?v=1ltYKckXiRc']


  let emailsSent = 0;
  Logger.log(`Found ${topTenVideos.length} videos. Beginning email sending process...`);

  // 2. FOR LOOP to send 10 separate emails (or fewer if fewer than 10 videos were found)
  for (let i = 0; i < topTenVideos.length; i++) {
      const videoURL = topTenVideos[i];
      const videoNumber = i + 1;

      // Build a unique HTML email body for this single video
      const emailSubject = `Cat Video Alert #${videoNumber} of ${topTenVideos.length}!`;
      
      let htmlBody = `
        <html>
          <body>
            <p>Hello Cat Lover, you left your email logged into a computer! That means it is time for me to do something silly with your account. You should be grateful that the your fellow cat lover found your accout and logged you out. Not before sending you tons of cat videos! </p>
            <p>Here is **Cat Video #${videoNumber}**:</p>
            <ul>
              <li><a href="${videoURL}">Click here to watch the Top Cat Video #${videoNumber}</a></li>
            </ul>
            <p>Please be sure to log out in the future.....</p>
            <p>— Made with Google Apps Script and Gemini</p>
          </body>
        </html>
      `;

      // Send the individual email using MailApp
      MailApp.sendEmail({
        to: RECEIVER_EMAIL,
        subject: emailSubject,
        htmlBody: htmlBody,
      });

      emailsSent++;
      // Log the action for the user to track progress
      Logger.log(`✅ Sent email ${videoNumber} to ${RECEIVER_EMAIL}. URL: ${videoURL}`);
      //Logger.log(videoURL);
  }
  
  Logger.log(`Finished sending. Total of ${emailsSent} separate emails successfully delivered.`);
}
