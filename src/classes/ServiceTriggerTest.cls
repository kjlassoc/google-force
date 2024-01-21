@isTest(SeeAllData=true)
public with sharing class ServiceTriggerTest {
    static testMethod void ServiceTrigger_Test() {
        List<Account> myAccounts = [select Id from Account limit 100];
        List<Product2> myProducts = [select Id from Product2 limit 100];
        List<Contact> myContacts = [select Id from Contact limit 100];
        Account myAccount = MyAccounts.get(0);
        myAccount.Services_Spreadsheet_Sheet_Id__c = '12345';
        update myAccount;
        Service_c__c myService = new Service_c__c();
        myService.Account__c = myAccount.Id;
        myService.Expired__c = false;
        myService.Invoice_sent__c = false;
        myService.License_end_date__c = Date.today().addDays(300);
        myService.License_start_date__c = Date.today().addDays(-300);
        myService.Note__c = 'Note';
        myService.Paid__c = true;
        myService.Product__c = myProducts.get(0).Id;
        myService.Purchase_Price__c = 1.00;
        myService.Renewal__c = false;
        myService.Sale_date__c = Date.today().addDays(-301);
        myService.Subscriber_name__c = myContacts.get(0).Id;
        insert myService;
        myService.Name = 'myService';
        update myService;
    }
}
