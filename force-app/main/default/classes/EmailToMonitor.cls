global class EmailToMonitor implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        List<String> emailBody = email.plainTextBody.split('\n', 0);
		System.debug('emailBody: ' + emailBody);
        
        String processName = emailBody[0]; // Monitor Name
        String processType = emailBody[1]; // Start or End
        String processResult = emailBody[2]; // Success or Error

        try {
			           
            Monitor__c monitor = new Monitor__c();
            List<Monitor__c> monitors = [SELECT Name FROM Monitor__c WHERE Name = :processName LIMIT 1];
            if(!monitors.isEmpty()) {
                monitor.Id = monitors[0].Id;
            }
            
            monitor.Name = processName;
            
            switch on processType {
                when 'Start' {
                    monitor.LastStartDatetime__c = System.now();
                    monitor.LastStartResult__c = processResult;
                }
                when 'End' {
                    monitor.LastEndDatetime__c = System.now();
                    monitor.LastEndResult__c = processResult;
                }
            }

			upsert monitor;   
        }
        catch (QueryException e) {
            System.debug('Query Issue: ' + e);
        }
        
        result.success = true;
        return result;
    }
}