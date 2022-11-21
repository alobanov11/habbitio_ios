//
//  Created by Антон Лобанов on 18.11.2022.
//

import SwiftUI

extension CGFloat {
    static var screenSize: CGRect {
        UIScreen.main.bounds
    }

    static var screenHeight: CGFloat {
        self.screenSize.height
    }
}
