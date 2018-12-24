@istest
public class FileUploaderSchedulerTest {
    static testmethod void test() {
        Test.startTest();

		String CRON_EXP = '0 0 23 1/1 * ? *';
        
        // Schedule the test job
        String jobId = System.schedule('FileUploaderSchedulerTest 2',CRON_EXP, new FileUploaderScheduler());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        
        Test.stopTest();
    }
}