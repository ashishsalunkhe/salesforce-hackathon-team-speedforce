public class CaseController {
    @AuraEnabled
    public static Case createCase(Case cases){
        upsert cases;
        return cases;
    }
}