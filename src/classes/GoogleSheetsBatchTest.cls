@isTest(SeeAllData=true)
public class GoogleSheetsBatchTest {
    private static final Integer BULK_SIZE = 10;

    @isTest
    static void testMethod1() {
        insertAccounts();

        Test.startTest();
        GoogleSheetsBatch obj = new GoogleSheetsBatch();
        DataBase.executeBatch(obj); 
        Test.stopTest();
    }

    private static void insertAccounts() {
        Account[] myAccounts = new Account[] {};      
        GoogleSheets.BatchGetValuesResponse batchGetValsRespMock = new GoogleSheets.BatchGetValuesResponse();
        Test.setMock(HttpCalloutMock.class, new GoogleMockResponse(200, 'OK', JSON.serialize(batchGetValsRespMock, true), null));
        List<Contact> myContacts = [select Id from Contact limit 100];
        for (Integer i = 0;i < BULK_SIZE;i ++) {            
            Account myAccount = new Account();            
            myAccount.Name = 'Test Account ' + i;
            myAccount.Website = 'https://www.myaccount' + i + '.com';
            myAccount.accountNumber = '123' + i;
            myAccount.BillingStreet = 'street abc' + i;
            myAccount.BillingCity = 'city' + i;
            myAccount.BillingState = 'state' + i;
            myAccount.BillingCountry = 'Ind';
            myAccount.BillingpostalCode = '30203' + i;
            myAccount.Services_Spreadsheet_Sheet_Id__c = '12345' + i;
            myAccount.Trainer_1__c = myContacts.get(0).Id;
            myAccount.Trainer_2__c = myContacts.get(1).Id;
            myAccount.Trainer_3__c = myContacts.get(2).Id;
            myAccount.PD_Contact__c = myContacts.get(3).Id;
            myAccounts.add(myAccount);                            
        }          
        Database.insert(myAccounts, false);
    }
}
