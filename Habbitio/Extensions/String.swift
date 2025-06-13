import Foundation

extension String: @retroactive LocalizedError {

	public var errorDescription: String? {
		return self
	}
}
