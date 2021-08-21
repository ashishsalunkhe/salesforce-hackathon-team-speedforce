@isTest
public class Zomato_Test {
	@isTest
    public static void test(){
        test.startTest();
        String locationName = 'Pune';
        ZomatoClass.getLocation(locationName);
        test.stopTest();
    }
}