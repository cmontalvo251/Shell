//Global Variables  
// First row of data to process
var startRow = 2;
// Number of rows to process
//var numStudents = 36; 
var numStudents = 4;
//number of columns to pull in
//var num_columns = 15;
var num_columns = 5;
//Name of course
var name_of_course = 'Spacecraft Design (AE 464)'

//Subject of email
var subject = 'Automated Update on Grades';
//Preamble of email.
var preamble = 'You are receiving an automated message from Google Apps Scripts run by Dr. Montalvo. \n \n';
//End of email
var endrant = 'Your final grade in the class will be whichever grade is higher. I will continue to compute grades using both methods as assignments are turned in for the remainder of the semester. If you believe there is an error in one of your grades or the computation of your grades please reply to this email.';

///Ok here is my main function loop
function loop() {
  //Get the active spreadhseet. Note this grabs the first sheet
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("AE464_YOUTUBE");
  
  //?Grab the data range for students - startRow and start Column, number of rows and columns
  var dataRange = sheet.getRange(startRow, 1, numStudents,num_columns);
  // Fetch values for each row in the Range.
  var data = dataRange.getValues();
  //Now let's loop through every row
  for (var i = 0; i < data.length; ++i) {
    var row = data[i];
    var emailAddress = row[1]; //Second column
    var name = row[0]; // First column
    //var percent_grade = row[7]; // 
    //var points_grade = row[13];
    var percent_grade = row[4];
    var dear = 'Hey ' + name + ', \n \n';
    //var gradeupdate = 'Your current grade in ' + name_of_course + ' is a ' + points_grade + '% using total points received / total points possible. \n \n';
    var gradeupdate = 'Your current grade in ' + name_of_course + ' is a ' + percent_grade + '%. \n \n';
    //var gradebreakdown = 'Your current grade using percentages defined in the syllabus is a ' + percent_grade + '% \n \n';
    //var message = dear + preamble + gradeupdate + gradebreakdown + endrant;
    var message = dear + preamble + gradeupdate + endrant;
    //Send Email
    //if (i == 0) {
    MailApp.sendEmail(emailAddress, subject, message);  
    //}
    var logmessage = name + ' ' + percent_grade + '\n';
    console.log(logmessage);
    sheet.getRange(startRow + i,6).setValue('Message Sent');
    // Make sure the cell is updated right away in case the script is interrupted
    SpreadsheetApp.flush(); 
  }
}
