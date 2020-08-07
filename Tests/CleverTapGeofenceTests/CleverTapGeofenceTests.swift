
import Quick
import Nimble
import OCMock
import CleverTapSDK
import CleverTapGeofence

final class CleverTapGeofenceTests: QuickSpec {
    
    override func spec() {
        
        describe("a CleverTapGeofence instance") {
            
            context("") {
                
                it("returns an singleton instance of CleverTapGeofence module") {
                    
                    let instance = CleverTapGeofence.monitor
                    
                    expect(instance).toNot(beNil())
                }
            }
        }
    }
}
