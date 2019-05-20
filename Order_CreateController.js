({  
    handleLoad: function(component, event, helper) {
        console.log('Form Loaded');
    },
    
    handleSubmit: function(component, event, helper) {
        console.log('Form Submitted Pricebook2Id');
    },
    
    handleSuccess: function(component, event) {
        var param = event.getParams(); //get event params
        var recordId = param.response.id; //get record id
        
        console.log("recordId = " + recordId);
        component.set("v.recordId", recordId);
        component.set("v.creatingOrder", false);
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Order_Items_Add",
            componentAttributes: {
                orderId : recordId
            }
        });
        evt.fire();
    },
    
    handleCancel: function(component, event, helper) {
        
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Order"
        });
        homeEvent.fire();
        /*var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/o/Order'
        });
        urlEvent.fire();*/
        
    }
})