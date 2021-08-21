global without sharing class accWithContController {
    @AuraEnabled
    public static list < Account > fetchAccount() {
      // query 10 records from account with their relevant contacts and return query.
    List < Account > lstOfAcc = [select Name, AnnualRevenue, BillingState, (select LastName from contacts) from Account LIMIT 10];
      return lstOfAcc;
    }
}