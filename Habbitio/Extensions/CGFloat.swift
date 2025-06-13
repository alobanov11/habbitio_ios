import SwiftUI

extension CGFloat {

    static var screenSize: CGRect {
        UIScreen.main.bounds
    }

    static var screenHeight: CGFloat {
        self.screenSize.height
    }
}
