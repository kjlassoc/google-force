public with sharing class ServiceTriggerController {
    public static void processServices(Service_c__c[] services) {
        for (Service_c__c service : services) {
            List<Account> myAccounts = [select Id, Services_Spreadsheet_Sheet_Id__c from Account where Id =: service.Account__c];
            if (myAccounts != null && myAccounts.size() > 0 && String.isNotEmpty(myAccounts.get(0).Services_Spreadsheet_Sheet_Id__c)) {
                updateServiceRecords(myAccounts.get(0).Services_Spreadsheet_Sheet_Id__c, service.Id);
            }
        }
    }

    @future(callout=true)
    public static void updateServiceRecords(String sheetId, Id serviceId) {
    }
}