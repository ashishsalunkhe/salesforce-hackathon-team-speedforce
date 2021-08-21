trigger ticketEMailTrigger on Ticket__c (after insert) {
    // Create a new single email message object 
    // that will send out a single email to the addresses in the To, CC & BCC list.
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
    set<id> ContactId = new set<id>();
    List<Messaging.SingleEmailMessage> mails =   new List<Messaging.SingleEmailMessage>();
    for (Ticket__c myContact:Trigger.new){
        		 if (myContact.Contact__c != null )
                {
                      ContactId.add(myContact.Contact__c);
                }
            	  
        		// Getting contact info
        		Contact con = [Select firstname,lastname,email,id,name,MobilePhone from Contact where id in :ContactId];
        		// Step 2: Set list of people who should get the email
                List<String> sendTo = new List<String>();
                sendTo.add(con.email);
              
                // Strings to hold the email addresses to which you are sending the email. 
                //String[] toAddresses = new String[] {'ashish_salunkhe@persistent.com'}; 
                //String[] ccAddresses = new String[] {'avsalunkhe98@gmail.com'}; 
                // Assign the addresses for the To and CC lists to the mail object. 
                mail.setToAddresses(sendTo); 
                // (Optional) Set list of people who should be CC'ed
                List<String> ccTo = new List<String>();
                ccTo.add('avsalunkhe98@gmail.com');
                mail.setCcAddresses(ccTo); 
                // Step 3: Set who the email is sent from
                mail.setReplyTo('megha_mane@persistent.com');
                mail.setSenderDisplayName('MahaMetroLink Pune');
                // Specify the subject line for your email address. 
                mail.setSubject('Ticket Booking Confirmed');
                String 	body = 'Dear <b>' + con.FirstName+'</b>,' +'<br/>'+'Your ticket booking has been confirmed with Ticket Id: <b>'+ myContact.Name+'</b><br/>';
                	   	body += '<b>Your Transit Details:</b> <br/>';
        				body += '<b>Source Location:</b> '+myContact.SourceLocation__c+'<br/>'+'<b>Destination Location:</b> '+myContact.DestinationLocation__c+'<br/>';
        				body += '<b>Boarding Time:</b> '+myContact.BookingTime__c+'<br/>';
        				body += '<b>Your Ticket Fare:</b> '+myContact.Ticket_Fare__c+'<br/>';
        				body += '<b>Your Ticket is valid till:</b> '+myContact.BookingTimeValidity__c+'<br/><br/>';
						body += 'Thank you for using MahaMetroLink Pune. Have a safe journey!';

        			   	//body += 'Please find your QR Code and present it at the junction if required <br/>';
                       	//body += IMAGE(myContact.QRCode__c);
                mail.setHtmlBody(body);
                // Set to True if you want to BCC yourself on the email. 
                mail.setBccSender(false); 
                // Optionally append the salesforce.com email signature to the email. 
                // The email address of the user executing the Apex Code will be used.
                String 	signature = 'Team MetroLink'+'<br/>';
        				signature += '<i>ticket@metrolink.com</i>'+'<br/>';
                mail.setUseSignature(false); 
                // Specify the text content of the email. 
               
                mails.add(mail); 
                System.debug('Email Sent Successfully to:: '+con.Email);
                // Send the email you have created. 
                //Messaging.sendEmail(mails); 
    }
            
    
}