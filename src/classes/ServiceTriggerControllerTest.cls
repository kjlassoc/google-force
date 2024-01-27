@isTest(SeeAllData=true)
public with sharing class ServiceTriggerControllerTest {
    static testMethod void processServicesTest() {
        Service_c__c[] myServices = [select Id, Account__c from Service_c__c limit 100];        
        Test.startTest();
        ServiceTriggerController.processServices(myServices);
        Test.stopTest();        
    }
}