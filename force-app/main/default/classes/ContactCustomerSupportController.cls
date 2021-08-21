public class ContactCustomerSupportController {
    @AuraEnabled
       public static  ContactCustomerSupportWrapper  createCase(String contactCustomerWrapper, Id recordId) 
           {
            ContactCustomerSupportWrapper caseDetails = new ContactCustomerSupportWrapper();
           //JSON Attributes
                   String jsonObject;
                   String jsonData;  
           Case  caseNew = new Case();
           List<Case>  updatedCaseList = new List<Case>();
           try
           {       
               
               Map<String,Object> cases = (Map<String,Object>)Json.deserializeUntyped(contactCustomerWrapper);
               
               Case caseObj = (Case)JSON.deserializeStrict(contactCustomerWrapper,Case.class); //edited
               
               //system.debug('caseObj--'+caseObj.Agreement_Value__c);
               List<Case>  caseList = [SELECT ContactPhone,ContactEmail,Subject,Description,Status
                                       from Case
                                       where  Id =: recordId Limit 1 ];
                  
               system.debug('caseList' + caseList);
               
               if(caseList.size()>0)
               {
                   //caseList[0].ContactId__r.Name =  caseObj.ContactId__r.Name;   
                   //caseList[0].ContactPhone =  caseObj.ContactPhone;
                   //caseList[0].ContactEmail =  caseObj.ContactEmail;
                   caseList[0].Subject =  caseObj.Subject;
                   caseList[0].Description =  caseObj.Description;
                   caseList[0].Status =  caseObj.Status;
                   
                   
                   system.debug('Iaddrlist[0]' + caseList[0]);                  
                   updatedCaseList.add(caseList[0]);
                   
                   if(updatedCaseList.size()>0)
                   {
                       database.upsert(updatedCaseList);
                   }
                   
                   else  {
                       /*MessageLogUtil.MessageLog exceptionLog=new MessageLogUtil.MessageLog(Constants.EXCEPTION_TYPE_OTHERS,Label.Invalid_Application, 
                                                                                            'No Rows To return from SOQl',Label.Invalid_Application,Label.Invalid_Application,'','',Constants.MESSAGE_TYPE_EXCEPTION,'',
                                                                                            'ContactCustomerSupportWrapper','createCase','','','','');
                       Log_Message__c exceptionInsLog  = MessageLogUtil.createExceptionMessageLog(exceptionLog);
                       transactionDtls.isErrorOccured=true;
                       transactionDtls.errorLog = exceptionInsLog;
                       system.debug(exceptionLog);
                       system.debug(loanApplciation);*/
                       System.debug('Error from ApexController Method');
                   }
                    
               } 
               
               else
               {
                  database.insert(caseObj);
                  caseDetails.cases =caseObj;  
               }
           }
           
           catch(Exception e){
               /*System.debug('Exception Details'+ex.getMessage() +'Line No :'+ ex.getLineNumber());
               MessageLogUtil.MessageLog exceptionLog =new MessageLogUtil.MessageLog(ex,'Apex','Exception occured while fetching Transaction Details', 'TransactionDetailsController.insertTransactionDetails',Ex.getMessage(),Ex.getMessage(),'',Ex.getLineNumber()+'','','','TransactionDetailController','insertTransactionDetails');
               Log_Message__c exceptionInsLog  = MessageLogUtil.createExceptionMessageLog(exceptionLog);
               System.debug('exceptionLog:: '+exceptionLog);
               transactionDtls.isErrorOccured = true;
               transactionDtls.errorLog = exceptionInsLog;
               system.debug(exceptionLog);*/
               System.debug('Error from ApexController Method' + e.getMessage());
           }
           system.debug('ss'+caseDetails);
           return caseDetails; 
       }

}