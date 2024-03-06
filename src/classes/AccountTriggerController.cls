public with sharing class AccountTriggerController {
    public static void processAccounts(Account[] accounts) {
        if (accounts != null) {
            for (Account account : accounts) {
                if (String.isNotEmpty(account.Services_Spreadsheet_Sheet_Id__c)) {
                    updateSpreadsheet(account.Services_Spreadsheet_Sheet_Id__c, account.Id);
                }
            }
        }
    }

    @future(callout=true)
    public static void updateSpreadsheet(String sheetId, Id accountId) {
        List<Account> myAccounts = [select Id, Name, Website, BillingAddress, Trainer_1__r.Name, Trainer_2__r.Name, Trainer_3__r.Name, PD_Contact__r.Name, PD_Contact__r.Email from Account where Id =: accountId];
        if (myAccounts.size() > 0) {
            Account myAccount = myAccounts.get(0);

            List<Service_c__c> myServices = [select Id, Name, Sale_date__c, Product__r.Name from Service_c__c where Account__c =: myAccount.Id and Product__r.Product_Type__c = 'License' and Expired__c = false];
            Date saleDate = null;

            for (Service_c__c myService : myServices) {
                if (myService.Sale_date__c > saleDate) {
                    saleDate = myService.Sale_date__c;
                }
            }

            String licenseString = getLicenseString(myAccount.Id);

            GoogleForce gForce = new GoogleForce('dreamforce');
            GoogleSheets sheets = new GoogleSheets(gForce);

            if (!Test.isRunningTest()) {
                sheets.spreadsheets().values().batchUpdateSheetProperty(
                    gForce.getServicesSpreadsheetId(), Integer.valueOf(sheetId), myAccount.Name)
                    .execute();
            }

            String trainers = '';

            if (myAccount.Trainer_1__c != null && String.isNotEmpty(myAccount.Trainer_1__r.Name)) {
                trainers = myAccount.Trainer_1__r.Name;
            }
            if (myAccount.Trainer_2__c != null && String.isNotEmpty(myAccount.Trainer_2__r.Name)) {
                trainers += ', ' + myAccount.Trainer_2__r.Name;
            }
            if (myAccount.Trainer_3__c != null && String.isNotEmpty(myAccount.Trainer_3__r.Name)) {
                trainers += ', ' + myAccount.Trainer_3__r.Name;
            }

            updateCellValues(sheets, gForce, myAccount.Name, 'A1', myAccount.Name);

            if (myAccount.BillingAddress != null) {
                String addr = myAccount.BillingAddress.getStreet() + ', ' + myAccount.BillingAddress.getCity() + ', ' + myAccount.BillingAddress.getState() + ', ' + myAccount.BillingAddress.getCountry();
                updateCellValues(sheets, gForce, myAccount.Name, 'B1', addr);
            }

            if (String.isNotEmpty(myAccount.Website)) {
                updateCellValues(sheets, gForce, myAccount.Name, 'A2', myAccount.Website);
            }

            if (String.isNotEmpty(trainers)) {
                updateCellValues(sheets, gForce, myAccount.Name, 'B6', trainers);
            }

            if (myAccount.PD_Contact__c != null && String.isNotEmpty(myAccount.PD_Contact__r.Name)) {
                updateCellValues(sheets, gForce, myAccount.Name, 'B3', myAccount.PD_Contact__r.Name);
            }

            if (myAccount.PD_Contact__c != null && String.isNotEmpty(myAccount.PD_Contact__r.Email)) {
                updateCellValues(sheets, gForce, myAccount.Name, 'B3', myAccount.PD_Contact__r.Email);
            }

            if (saleDate != null) {
                updateCellValues(sheets, gForce, myAccount.Name, 'B4', saleDate.format());
            }

            if (String.isNotEmpty(licenseString)) {
                updateCellValues(sheets, gForce, myAccount.Name, 'B5', licenseString);
            }

            List<String> values = new List<String>();
            values.add('This');
            values.add('Is');
            values.add('Test');
            values.add('Data');

            if (!Test.isRunningTest()) {
                sheets.spreadsheets().values().batchSetDataValidation(
                    gForce.getServicesSpreadsheetId(), Integer.valueOf(sheetId), 8, 8, 8, 9, values)
                    .execute();
            }
    
            gForce.updateToken();
        }
    }

    public static void updateCellValues(GoogleSheets sheets, GoogleForce gForce, String sheetTitle, String cellRangeAddress, String cellValue) {
        String cellRange = '\'' + EncodingUtil.urlEncode(sheetTitle, 'UTF-8') + '\'!' + cellRangeAddress;

        if (Test.isRunningTest()) {
            return;
        }

        GoogleSheets.ValueRange valueRange = new GoogleSheets.ValueRange()
            .setMajorDimension('ROWS')
            .setValues(new List<List<String>>{
                new List<String>{ cellValue }
            });

        GoogleSheets.UpdateValuesResponse valsResp = sheets.spreadsheets().values().updateRange(
            gForce.getServicesSpreadsheetId(), cellRange, valueRange)
            .setIncludeValuesInResponse(true)
            .setValueInputOption('USER_ENTERED')
            .execute();
    }

    public static String getLicenseString(Id accountId) {
        List<Service_c__c> myServices = [select Id, Name, Sale_date__c, Product__r.Name from Service_c__c where Account__c =: accountId and Product__r.Product_Type__c = 'License' and Expired__c = false];
        Map<String, Integer> productMap = new Map<String, Integer>();

        for (Service_c__c myService : myServices) {
            if (productMap.get(myService.Product__r.Name) != null) {
                Integer count = productMap.get(myService.Product__r.Name);
                productMap.put(myService.Product__r.Name, ++count);
            } else {
                productMap.put(myService.Product__r.Name, 1);
            }
        }

        String licenseString = null;

        for (String productName : productMap.keySet()) {
            if (licenseString == null) {
                licenseString = productMap.get(productName) + ' ' + productName;
            } else {
                licenseString += ', ' + productMap.get(productName) + ' ' + productName;
            }
        }

        return licenseString;
    }
}