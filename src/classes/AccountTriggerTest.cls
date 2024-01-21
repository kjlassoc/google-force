@isTest(SeeAllData=true)
public with sharing class AccountTriggerTest {
    static testMethod void AccountTrigger_Test() {
        GoogleSheets.BatchGetValuesResponse batchGetValsRespMock = new GoogleSheets.BatchGetValuesResponse();
        Test.setMock(HttpCalloutMock.class, new GoogleMockResponse(200, 'OK', JSON.serialize(batchGetValsRespMock, true), null));
        List<Contact> myContacts = [select Id from Contact limit 100];
        Account myAccount = new Account(Name='myAccount');
        myAccount.Website = 'https://www.myaccount.com';
        myAccount.accountNumber = '123';
        myAccount.BillingStreet = 'street abc1';
        myAccount.BillingCity = 'Chicago';
        myAccount.BillingState = 'Illinois';
        myAccount.BillingCountry = 'United States';
        myAccount.BillingpostalCode = '302039';
        myAccount.Services_Spreadsheet_Sheet_Id__c = '12345';
        myAccount.Trainer_1__c = myContacts.get(0).Id;
        myAccount.Trainer_2__c = myContacts.get(1).Id;
        myAccount.Trainer_3__c = myContacts.get(2).Id;
        myAccount.PD_Contact__c = myContacts.get(3).Id;
        insert myAccount;
        myAccount.Name = 'myAccount';
        update myAccount;
    }
}
