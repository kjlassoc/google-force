public class GoogleSheets {

    private static final String rootUrl = 'https://sheets.googleapis.com/v4/spreadsheets';
    private GoogleForce gForce;

    public GoogleSheets() {
    }

    public GoogleSheets(GoogleForce gForce) {
        this.gForce = gForce;
    }

    public class Spreadsheets {
        private GoogleSheets gSheet;

        public Spreadsheets(GoogleSheets gSheet) {
            this.gSheet = gSheet;
        }

        public Values values() {
            return new Values(this);
        }
    }

    public class Values {
        private Spreadsheets gSpreadsheet;

        public Values(Spreadsheets gSpreadsheet) {
            this.gSpreadsheet = gSpreadsheet;
        }

        public BatchGet batchGet(String spreadsheetId) {
            return new BatchGet(this, spreadsheetId);
        }

        public BatchSetDataValidation batchSetDataValidation(String spreadsheetId, Integer sheetId, Integer startRowIndex, Integer endRowIndex, Integer startColumnIndex, Integer endColumnIndex, List<String> values) {
            return new BatchSetDataValidation(this, spreadsheetId, sheetId, startRowIndex, endRowIndex, startColumnIndex, endColumnIndex, values);
        }

        public BatchUpdateSheetProperty batchUpdateSheetProperty(String spreadsheetId, Integer sheetId, String title) {
            return new BatchUpdateSheetProperty(this, spreadsheetId, sheetId, title);
        }

        public BatchUpdate batchUpdate(String spreadsheetId, BatchUpdateRequest content) {
            return new BatchUpdate(this, spreadsheetId, content);
        }

        public GetRange getRange(String spreadsheetId, String range) {
            return new GetRange(this, spreadsheetId, range);
        }

        public UpdateRange updateRange(String spreadsheetId, String range, ValueRange valueRange) {
            return new UpdateRange(this, spreadsheetId, range, valueRange);
        }

        public Get get(String spreadsheetId) {
            return new Get(this, spreadsheetId);
        }

        public CopyTo copyTo(String sourceSpreadsheetId, String destinationSpreadsheetId, Integer sheetId) {
            return new CopyTo(this, sourceSpreadsheetId, destinationSpreadsheetId, sheetId);
        }
    }

    public class BatchGet {

        private Values gValues;
        private String queryParams;
        private String spreadsheetId;

        public BatchGet(Values gValues, String spreadsheetId) {
            this.gValues = gValues;
            this.queryParams = '';
            this.spreadsheetId = spreadsheetId;
        }

        public BatchGet setDateTimeRenderOption(String dateTimeRenderOption) {
            queryParams = gValues.gSpreadsheet.gSheet.appendParam(queryParams,
                'dateTimeRenderOption', dateTimeRenderOption);
            return this;
        }

        public BatchGet setMajorDimension(String majorDimension) {
            queryParams = gValues.gSpreadsheet.gSheet.appendParam(queryParams,
                'majorDimension', majorDimension);
            return this;
        }

        public BatchGet setRanges(List<String> ranges) {
            for (String range : ranges) {
                queryParams = gValues.gSpreadsheet.gSheet.appendParam(queryParams,
                    'ranges', range);
            }
            return this;
        }

        public BatchGet setValueRenderOption(String valueRenderOption) {
            queryParams = gValues.gSpreadsheet.gSheet.appendParam(queryParams,
                'valueRenderOption', valueRenderOption);
            return this;
        }

        public BatchGetValuesResponse execute() {
            String endpoint = GoogleSheets.rootUrl + '/' + spreadsheetId + '/values:batchGet';

            GoogleForce gForce = gValues.gSpreadsheet.gSheet.gForce;
            HttpResponse resp = gForce.sendRequest(new Map<String, String>{
                'method'   => 'GET',
                'endpoint' => endpoint + queryParams
            });

            return (BatchGetValuesResponse) JSON.deserialize(
                gForce.handleResponse(resp), BatchGetValuesResponse.class);
        }
    }

    public class BatchGetValuesResponse {
        private String spreadsheetId;
        private List<ValueRange> valueRanges;

        public String getSpreadsheetId() {
            return spreadsheetId;
        }

        public List<ValueRange> getValueRanges() {
            return valueRanges;
        }

        public BatchGetValuesResponse setSpreadsheetId(String spreadsheetId) {
            this.spreadsheetId = spreadsheetId;
            return this;
        }

        public BatchGetValuesResponse setValueRanges(List<ValueRange> valueRanges) {
            this.valueRanges = valueRanges;
            return this;
        }
    }

    public class BatchSetDataValidation {
        private Values gValues;
        private String spreadsheetId;
        private Integer sheetId;
        private Integer startRowIndex;
        private Integer endRowIndex;
        private Integer startColumnIndex;
        private Integer endColumnIndex;
        private List<String> dataValues;
        private BatchSetDataRequest batchSetDataRequest;

        public BatchSetDataValidation() {
        }

        public BatchSetDataValidation(Values gValues, String spreadsheetId, Integer sheetId, Integer startRowIndex, Integer endRowIndex, Integer startColumnIndex, Integer endColumnIndex, List<String> dataValues) {
            this.gValues = gValues;
            this.spreadsheetId = spreadsheetId;
            this.sheetId = sheetId;
            this.startRowIndex = startRowIndex;
            this.endRowIndex = endRowIndex;
            this.startColumnIndex = startColumnIndex;
            this.endColumnIndex = endColumnIndex;
            this.dataValues = dataValues;

            GoogleSheets.GridRange gridRange = new GoogleSheets.GridRange();
            gridRange.setSheetId(sheetId);
            gridRange.setStartRowIndex(startRowIndex);
            gridRange.setEndRowIndex(endRowIndex);
            gridRange.setStartColumnIndex(startColumnIndex);
            gridRange.setEndColumnIndex(endColumnIndex);

            List<GoogleSheets.ConditionValue> conditionValues = new List<GoogleSheets.ConditionValue>();
            for (String dataValue : dataValues) {
                ConditionValue conditionValue = new ConditionValue();
                conditionValue.setUserEnteredValue(dataValue);
                conditionValues.add(conditionValue);
            }
 
            GoogleSheets.BooleanCondition booleanCondition = new BooleanCondition();
            booleanCondition.setType('ONE_OF_LIST');
            booleanCondition.setValues(conditionValues);

            GoogleSheets.DataValidationRule dataValidationRule = new GoogleSheets.DataValidationRule();
            dataValidationRule.setCondition(booleanCondition);
            dataValidationRule.setShowCustomUi(true);
            dataValidationRule.setStrict(true);

            GoogleSheets.SetDataValidationRequest setDataValidationRequest = new SetDataValidationRequest();
            setDataValidationRequest.setRange(gridRange);
            setDataValidationRequest.setRule(dataValidationRule);

            GoogleSheets.SetDataRequest setDataRequest = new GoogleSheets.SetDataRequest();
            setDataRequest.setSetDataValidationRequest(setDataValidationRequest);

            GoogleSheets.BatchSetDataRequest batchSetDataRequest = new GoogleSheets.BatchSetDataRequest();
            List<GoogleSheets.SetDataRequest> requests = new List<GoogleSheets.SetDataRequest>();
            requests.add(setDataRequest);
            batchSetDataRequest.setRequests(requests);
            this.batchSetDataRequest = batchSetDataRequest;
        }

        public void execute() {
            String endpoint = GoogleSheets.rootUrl + '/' + spreadsheetId + ':batchUpdate';
            String jsonBody = JSON.serialize(batchSetDataRequest, true);
System.debug('----->' + JSON.serializePretty(batchSetDataRequest));
            GoogleForce gForce = gValues.gSpreadsheet.gSheet.gForce;
            HttpResponse resp = gForce.sendRequest(new Map<String, String>{
                'method'   => 'POST',
                'endpoint' => endpoint,
                'body' => jsonBody
            });

            return;
        }
    }

    public class BatchUpdateSheetProperty {
        private Values gValues;
        private String spreadsheetId;
        private Integer sheetId;
        private String title;
        private BatchUpdateSheetRequest batchUpdateSheetRequest;

        public BatchUpdateSheetProperty() {
        }

        public BatchUpdateSheetProperty(Values gValues, String spreadsheetId, Integer sheetId, String title) {
            this.gValues = gValues;
            this.spreadsheetId = spreadsheetId;
            this.sheetId = sheetId;
            this.title = title;

            GoogleSheets.SheetProperties sheetProperties = new GoogleSheets.SheetProperties();
            sheetProperties.setSheetId(sheetId);
            sheetProperties.setTitle(title);
            GoogleSheets.UpdateSheetPropertiesRequest updateSheetPropertiesRequest = new GoogleSheets.UpdateSheetPropertiesRequest();
            updateSheetPropertiesRequest.setProperties(sheetProperties);
            updateSheetPropertiesRequest.setFields('title');
            GoogleSheets.UpdateSheetRequest updateSheetRequest = new GoogleSheets.UpdateSheetRequest();
            updateSheetRequest.setUpdateSheetPropertiesRequest(updateSheetPropertiesRequest);
            GoogleSheets.BatchUpdateSheetRequest batchUpdateSheetRequest = new GoogleSheets.BatchUpdateSheetRequest();
            List<GoogleSheets.UpdateSheetRequest> requests = new List<GoogleSheets.UpdateSheetRequest>();
            requests.add(updateSheetRequest);
            batchUpdateSheetRequest.setRequests(requests);
            this.batchUpdateSheetRequest = batchUpdateSheetRequest;
        }

        public void execute() {
            String endpoint = GoogleSheets.rootUrl + '/' + spreadsheetId + ':batchUpdate';
            String jsonBody = JSON.serialize(batchUpdateSheetRequest, true);

            GoogleForce gForce = gValues.gSpreadsheet.gSheet.gForce;
            HttpResponse resp = gForce.sendRequest(new Map<String, String>{
                'method'   => 'POST',
                'endpoint' => endpoint,
                'body' => jsonBody
            });

            return;
        }
    }

    public class BatchUpdateSheetRequest {
        private List<UpdateSheetRequest> requests;

        public List<UpdateSheetRequest> getRequests() {
            return requests;
        }

        public BatchUpdateSheetRequest setRequests(List<UpdateSheetRequest> requests) {
            this.requests = requests;
            return this;
        }
    }

    public class BatchUpdate {

        private Values gValues;
        private String spreadsheetId;
        private BatchUpdateRequest content;

        public BatchUpdate(Values gValues, String spreadsheetId, BatchUpdateRequest content) {
            this.gValues = gValues;
            this.spreadsheetId = spreadsheetId;
            this.content = content;
        }

        public BatchUpdateValuesResponse execute() {
            String endpoint = GoogleSheets.rootUrl + '/' + spreadsheetId + '/values:batchUpdate';
            String jsonBody = JSON.serialize(content, true);

            GoogleForce gForce = gValues.gSpreadsheet.gSheet.gForce;
            HttpResponse resp = gForce.sendRequest(new Map<String, String>{
                'method'   => 'POST',
                'endpoint' => endpoint,
                'body' => jsonBody
            });

            return (BatchUpdateValuesResponse) JSON.deserialize(
                gForce.handleResponse(resp), BatchUpdateValuesResponse.class);
        }

    }

    public class BatchUpdateRequest {
        private List<ValueRange> data;
        private Boolean includeValuesInResponse;
        private String responseDateTimeRenderOption;
        private String responseValueRenderOption;
        private String valueInputOption;

        public BatchUpdateRequest setData(List<ValueRange> data) {
            this.data = data;
            return this;
        }

        public BatchUpdateRequest setIncludeValuesInResponse(Boolean includeValuesInResponse) {
            this.includeValuesInResponse = includeValuesInResponse;
            return this;
        }

        public BatchUpdateRequest setResponseDateTimeRenderOption(String responseDateTimeRenderOption) {
            this.responseDateTimeRenderOption = responseDateTimeRenderOption;
            return this;
        }

        public BatchUpdateRequest setResponseValueRenderOption(String responseValueRenderOption) {
            this.responseValueRenderOption = responseValueRenderOption;
            return this;
        }

        public BatchUpdateRequest setValueInputOption(String valueInputOption) {
            this.valueInputOption = valueInputOption;
            return this;
        }
    }

    public class BatchUpdateValuesResponse {
        private List<UpdateValuesResponse> responses;
        private String  spreadsheetId;
        private Integer totalUpdatedCells;
        private Integer totalUpdatedColumns;
        private Integer totalUpdatedRows;
        private Integer totalUpdatedSheets;

        public List<UpdateValuesResponse> getResponses() {
            return responses;
        }

        public String getSpreadsheetId() {
            return spreadsheetId;
        }

        public Integer getTotalUpdatedCells() {
            return totalUpdatedCells;
        }

        public Integer getTotalUpdatedColumns() {
            return totalUpdatedColumns;
        }

        public Integer getTotalUpdatedRows() {
            return totalUpdatedRows;
        }

        public Integer getTotalUpdatedSheets() {
            return totalUpdatedSheets;
        }

        public BatchUpdateValuesResponse setResponses(List<UpdateValuesResponse> responses) {
            this.responses = responses;
            return this;
        }

        public BatchUpdateValuesResponse setSpreadsheetId(String spreadsheetId) {
            this.spreadsheetId = spreadsheetId;
            return this;
        }

        public BatchUpdateValuesResponse setTotalUpdatedCells(Integer totalUpdatedCells) {
            this.totalUpdatedCells = totalUpdatedCells;
            return this;
        }

        public BatchUpdateValuesResponse setTotalUpdatedColumns(Integer totalUpdatedColumns) {
            this.totalUpdatedColumns = totalUpdatedColumns;
            return this;
        }

        public BatchUpdateValuesResponse setTotalUpdatedRows(Integer totalUpdatedRows) {
            this.totalUpdatedRows = totalUpdatedRows;
            return this;
        }

        public BatchUpdateValuesResponse setTotalUpdatedSheets(Integer totalUpdatedSheets) {
            this.totalUpdatedSheets = totalUpdatedSheets;
            return this;
        }
    }

    public class Get {
        private Values gValues;
        private String spreadsheetId;

        public Get() {
        }

        public Get(Values gValues, String spreadsheetId) {
            this.gValues = gValues;
            this.spreadsheetId = spreadsheetId;
        }

        public List<Sheet> execute() {
            String endpoint = GoogleSheets.rootUrl + '/' + spreadsheetId;

            GoogleForce gForce = gValues.gSpreadsheet.gSheet.gForce;
            HttpResponse resp = gForce.sendRequest(new Map<String, String>{
                'method'   => 'GET',
                'endpoint' => endpoint
            });

            String getResponse = gForce.handleResponse(resp);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(getResponse);
            List<Sheet> sheetsResp = new List<Sheet>();

            for (Object s : (List<Object>) m.get('sheets')) {
            }

            return sheetsResp;
        }
    }

    public class CopyTo {

        private Values gValues;
        private String sourceSpreadsheetId;
        private String destinationSpreadsheetId;
        private Integer sheetId;

        public CopyTo(Values gValues, String sourceSpreadsheetId, String destinationSpreadsheetId, Integer sheetId) {
            this.gValues = gValues;
            this.sourceSpreadsheetId = sourceSpreadsheetId;
            this.destinationSpreadsheetId = destinationSpreadsheetId;
            this.sheetId = sheetId;
        }

        public Sheet execute() {
            String endpoint = GoogleSheets.rootUrl + '/' + sourceSpreadsheetId + '/sheets/' + sheetId + ':copyTo';
            CopyToRequest copyToRequest = new CopyToRequest(destinationSpreadsheetId);
            String jsonBody = JSON.serialize(copyToRequest, true);

            GoogleForce gForce = gValues.gSpreadsheet.gSheet.gForce;
            HttpResponse resp = gForce.sendRequest(new Map<String, String>{
                'method'   => 'POST',
                'endpoint' => endpoint,
                'body' => jsonBody
            });

            String copyToResponse = gForce.handleResponse(resp);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(copyToResponse);
            Integer destinationSheetId = (Integer) m.get('sheetId');
            String destinationTitle = (String) m.get('title');

            return new Sheet(destinationSheetId, destinationTitle);
        }
    }

    public class CopyToRequest {
        String destinationSpreadsheetId;

        public String getDestinationSpreadsheetId() {
            return destinationSpreadsheetId;
        }

        public CopyToRequest(String destinationSpreadsheetId) {
            this.destinationSpreadsheetId = destinationSpreadsheetId;
        }
    }

    public class Sheet {
        private Integer sheetId;
        private String title;

        public Integer getSheetId() {
            return sheetId;
        }

        public Sheet setSheetId(Integer sheetId) {
            this.sheetId = sheetId;
            return this;
        }

        public String getTitle() {
            return title;
        }

        public Sheet setTitle(String title) {
            this.title = title;
            return this;
        }

        public Sheet(Integer sheetId, String title) {
            this.sheetId = sheetId;
            this.title = title;
        }
    }

    public class GetRange {

        private Values gValues;
        private String queryParams;
        private String range;
        private String spreadsheetId;

        public GetRange(Values gValues, String spreadsheetId, String range) {
            this.gValues = gValues;
            this.queryParams = '';
            this.range = range;
            this.spreadsheetId = spreadsheetId;
        }

        public GetRange setDateTimeRenderOption(String dateTimeRenderOption) {
            queryParams = gValues.gSpreadsheet.gSheet.appendParam(queryParams,
                'dateTimeRenderOption', dateTimeRenderOption);
            return this;
        }

        public GetRange setMajorDimension(String majorDimension) {
            queryParams = gValues.gSpreadsheet.gSheet.appendParam(queryParams,
                'majorDimension', majorDimension);
            return this;
        }

        public GetRange setValueRenderOption(String valueRenderOption) {
            queryParams = gValues.gSpreadsheet.gSheet.appendParam(queryParams,
                'valueRenderOption', valueRenderOption);
            return this;
        }

        public ValueRange execute() {
            String endpoint = GoogleSheets.rootUrl + '/' + spreadsheetId + '/values/' + range;

            GoogleForce gForce = gValues.gSpreadsheet.gSheet.gForce;
            HttpResponse resp = gForce.sendRequest(new Map<String, String>{
                'method'   => 'GET',
                'endpoint' => endpoint + queryParams
            });

            return (ValueRange) JSON.deserialize(
                gForce.handleResponse(resp), ValueRange.class);
        }
    }

    public class UpdateRange {
        private ValueRange content;
        private Values gValues;
        private String queryParams;
        private String range;
        private String spreadsheetId;

        public UpdateRange(Values gValues, String spreadsheetId, String range, ValueRange content) {
            this.content = content;
            this.gValues = gValues;
            this.queryParams = '';
            this.range = range;
            this.spreadsheetId = spreadsheetId;
        }

        public UpdateRange setIncludeValuesInResponse(Boolean includeValuesInResponse) {
            queryParams = gValues.gSpreadsheet.gSheet.appendParam(queryParams,
                'includeValuesInResponse', String.valueOf(includeValuesInResponse));
            return this;
        }

        public UpdateRange setResponseDateTimeRenderOption(String dateTimeRenderOption) {
            queryParams = gValues.gSpreadsheet.gSheet.appendParam(queryParams,
                'responseDateTimeRenderOption', dateTimeRenderOption);
            return this;
        }

        public UpdateRange setResponseValueRenderOption(String valueRenderOption) {
            queryParams = gValues.gSpreadsheet.gSheet.appendParam(queryParams,
                'responseValueRenderOption', valueRenderOption);
            return this;
        }

        public UpdateRange setValueInputOption(String valueInputOption) {
            queryParams = gValues.gSpreadsheet.gSheet.appendParam(queryParams,
                'valueInputOption', valueInputOption);
            return this;
        }

        public UpdateValuesResponse execute() {
            String endpoint = GoogleSheets.rootUrl + '/' + spreadsheetId + '/values/' + range;
            String jsonBody = JSON.serialize(content, true);

            GoogleForce gForce = gValues.gSpreadsheet.gSheet.gForce;
            HttpResponse resp = gForce.sendRequest(new Map<String, String>{
                'method'   => 'PUT',
                'endpoint' => endpoint + queryParams,
                'body' => jsonBody
            });

            return (UpdateValuesResponse) JSON.deserialize(
                gForce.handleResponse(resp), UpdateValuesResponse.class);
        }

    }

    public class UpdateValuesResponse {
        private String     spreadsheetId;
        private Integer    updatedCells;
        private Integer    updatedColumns;
        private ValueRange updatedData;
        private String     updatedRange;
        private Integer    updatedRows;

        public String getSpreadsheetId() {
            return spreadsheetId;
        }

        public Integer getUpdatedCells() {
            return updatedCells;
        }

        public Integer getUpdatedColumns() {
            return updatedColumns;
        }

        public ValueRange getUpdatedData() {
            return updatedData;
        }

        public String getUpdatedRange() {
            return updatedRange;
        }

        public Integer getUpdatedRows() {
            return updatedRows;
        }

        public UpdateValuesResponse setSpreadsheetId(String spreadsheetId) {
            this.spreadsheetId = spreadsheetId;
            return this;
        }

        public UpdateValuesResponse setUpdatedCells(Integer updatedCells) {
            this.updatedCells = updatedCells;
            return this;
        }

        public UpdateValuesResponse setUpdatedColumns(Integer updatedColumns) {
            this.updatedColumns = updatedColumns;
            return this;
        }

        public UpdateValuesResponse setUpdatedData(ValueRange updatedData) {
            this.updatedData = updatedData;
            return this;
        }

        public UpdateValuesResponse setUpdatedRange(String updatedRange) {
            this.updatedRange = updatedRange;
            return this;
        }

        public UpdateValuesResponse setUpdatedRows(Integer updatedRows) {
            this.updatedRows = updatedRows;
            return this;
        }
    }

    public class UpdateSheetRequest {
        private UpdateSheetPropertiesRequest updateSheetProperties;

        public UpdateSheetPropertiesRequest getUpdateSheetPropertiesRequest() {
            return updateSheetProperties;
        }

        public UpdateSheetRequest setUpdateSheetPropertiesRequest(UpdateSheetPropertiesRequest updateSheetProperties) {
            this.updateSheetProperties = updateSheetProperties;
            return this;
        }
    }

    public class UpdateSheetPropertiesRequest {
        private SheetProperties properties;
        private String fields;

        public SheetProperties getProperties() {
            return properties;
        }

        public UpdateSheetPropertiesRequest setProperties(SheetProperties properties) {
            this.properties = properties;
            return this;
        }

        public String getFields() {
            return fields;
        }

        public UpdateSheetPropertiesRequest setFields(String fields) {
            this.fields = fields;
            return this;
        }
    }

    public class SheetProperties {
        private Integer sheetId;
        private String title;

        public Integer getSheetId() {
            return sheetId;
        }

        public SheetProperties setSheetId(Integer sheetId) {
            this.sheetId = sheetId;
            return this;
        }

        public String getTitle() {
            return title;
        }

        public SheetProperties setTitle(String title) {
            this.title = title;
            return this;
        }
    }

    public class GridRange {
        private Integer sheetId;
        private Integer startRowIndex;
        private Integer endRowIndex;
        private Integer startColumnIndex;
        private Integer endColumnIndex;

        public Integer getSheetId() {
            return sheetId;
        }

        public GridRange setSheetId(Integer sheetId) {
            this.sheetId = sheetId;
            return this;
        }

        public Integer getStartRowIndex() {
            return startRowIndex;
        }

        public GridRange setStartRowIndex(Integer startRowIndex) {
            this.startRowIndex = startRowIndex;
            return this;
        }

        public Integer getEndRowIndex() {
            return endRowIndex;
        }

        public GridRange setEndRowIndex(Integer endRowIndex) {
            this.endRowIndex = endRowIndex;
            return this;
        }

        public Integer getStartColumnIndex() {
            return startColumnIndex;
        }

        public GridRange setStartColumnIndex(Integer startColumnIndex) {
            this.startColumnIndex = startColumnIndex;
            return this;
        }

        public Integer getEndColumnIndex() {
            return endColumnIndex;
        }

        public GridRange setEndColumnIndex(Integer endColumnIndex) {
            this.endColumnIndex = endColumnIndex;
            return this;
        }
    }

    public class ConditionValue {
        private String userEnteredValue;

        public ConditionValue setUserEnteredValue(String userEnteredValue) {
            this.userEnteredValue = userEnteredValue;
            return this;
        }
    }

    public class BooleanCondition {
        private String type;
        private List<ConditionValue> values;

        public BooleanCondition setType(String type) {
            this.type = type;
            return this;
        }

        public BooleanCondition setValues(List<ConditionValue> values) {
            this.values = values;
            return this;
        }
    }

    public class DataValidationRule {
        private BooleanCondition condition;
        private Boolean showCustomUi;
        private Boolean strict;

        public DataValidationRule setCondition(BooleanCondition condition) {
            this.condition = condition;
            return this;
        }

        public DataValidationRule setShowCustomUi(Boolean showCustomUi) {
            this.showCustomUi = showCustomUi;
            return this;
        }

        public DataValidationRule setStrict(Boolean strict) {
            this.strict = strict;
            return this;
        }
    }

    public class ValueRange {
        private String range;
        private String majorDimension;
        private List<List<String>> values;

        public String getMajorDimension() {
            return majorDimension;
        }

        public String getRange() {
            return range;
        }

        public List<List<String>> getValues() {
            return values;
        }

        public ValueRange setMajorDimension(String majorDimension) {
            this.majorDimension = majorDimension;
            return this;
        }

        public ValueRange setRange(String range) {
            this.range = range;
            return this;
        }

        public ValueRange setValues(List<List<String>> values) {
            this.values = values;
            return this;
        }
    }

    public class SetDataRequest {
        private SetDataValidationRequest setDataValidation;

        public SetDataValidationRequest getSetDataValidationRequest() {
            return setDataValidation;
        }

        public SetDataRequest setSetDataValidationRequest(SetDataValidationRequest setDataValidation) {
            this.setDataValidation = setDataValidation;
            return this;
        }
    }

    public class SetDataValidationRequest {
        private GridRange range;
        private DataValidationRule rule;

        public GridRange getRange() {
            return range;
        }

        public SetDataValidationRequest setRange(GridRange range) {
            this.range = range;
            return this;
        }

        public DataValidationRule getRule() {
            return rule;
        }

        public SetDataValidationRequest setRule(DataValidationRule rule) {
            this.rule = rule;
            return this;
        }
    }

    public class BatchSetDataRequest {
        private List<SetDataRequest> requests;

        public List<SetDataRequest> getRequests() {
            return requests;
        }

        public BatchSetDataRequest setRequests(List<SetDataRequest> requests) {
            this.requests = requests;
            return this;
        }
    }

    private String appendParam(String queryParams, String key, String value) {

        if (String.isEmpty(queryParams)) {
            queryParams = '?' + key + '=' + value;
        } else {
            queryParams += '&' + key + '=' + value;
        }

        return queryParams;
    }

    public Spreadsheets spreadsheets() {
        return new Spreadsheets(this);
    }
}
