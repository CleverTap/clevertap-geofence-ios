import Quick
import Nimble
import OCMock
import CleverTapSDK
import CleverTapGeofence

final class CleverTapGeofenceTests: QuickSpec {
    
    override func spec() {
        
        describe("a CleverTapGeofence instance") {
            
            it("returns an singleton instance of CleverTapGeofence module") {
                
                let instance = CleverTapGeofence.monitor
                
                expect(instance).toNot(beNil())
            }
            
            it("starts geofence module") {
                
                CleverTap.setCredentialsWithAccountID("AccountID", andToken: "Token")
                CleverTapGeofence.monitor.start(didFinishLaunchingWithOptions: nil)
                
                let cleverTapInstance = CleverTap.sharedInstance()
                expect(cleverTapInstance).toNot(beNil())
            }
            
            it("stops geofence module") {
                
                CleverTap.setCredentialsWithAccountID("AccountID", andToken: "Token")
                CleverTapGeofence.monitor.stop()
                
                let cleverTapInstance = CleverTap.sharedInstance()
                expect(cleverTapInstance).toNot(beNil())
            }
        }
    }
}
