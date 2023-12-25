import Foundation



public extension Sequence {
	
	/**
	 Transform the sequence into a single element by applying a block on an initial value with all the items in the element.
	 
	 The closure calls will be performed in order, by waiting for each call to complete before proceeding with the next one.
	 If any of the closure calls throw an error, then the iteration will be terminated and the error rethrown.
	 
	 - parameter transform: The transform to run at each iteration.
	 - returns: The transformed initial value.
	 - throws: Rethrows any error thrown by the passed closure. */
	func asyncReduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) async throws -> Result) async rethrows -> Result {
		var result = initialResult
		
		for element in self {
			result = try await nextPartialResult(result, element)
		}
		
		return result
	}
	
	/* Note: We do not implement the concurrent version of the reduce method as it’s not clear what it would be supposed to do. */
	
}
