global class GoogleSheetsBatch implements Database.Batchable<sObject> ,Schedulable  {
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        return Database.getQueryLocator([SELECT Id from Account WHERE Services_Spreadsheet_Sheet_Id__c != null]);
    }
    
    global void execute(SchedulableContext SC) {
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug('scope is ' + scope);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}