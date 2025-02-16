import Foundation
import XCTest

@testable import CollectionConcurrencyKit



final class FlatMapTests : TestCase {
	
	func testNonThrowingAsyncFlatMap() {
		runAsyncTest{ array, collector in
			let values = await array.asyncFlatMap{
				await collector.collectAndDuplicate($0)
			}
			
			XCTAssertEqual(values, array.flatMap{ [$0, $0] })
		}
	}
	
	func testThrowingAsyncFlatMapThatDoesNotThrow() {
		runAsyncTest{ array, collector in
			let values = try await array.asyncFlatMap{
				try await collector.tryCollectAndDuplicate($0)
			}
			
			XCTAssertEqual(values, array.flatMap{ [$0, $0] })
		}
	}
	
	func testThrowingAsyncFlatMapThatThrows() {
		runAsyncTest{ array, collector in
			await self.verifyErrorThrown{ error in
				try await array.asyncFlatMap{ int in
					try await collector.tryCollectAndDuplicate(
						int,
						throwError: int == 3 ? error : nil
					)
				}
			}
			
			XCTAssertEqual(collector.values, [0, 1, 2])
		}
	}
	
	func testNonThrowingConcurrentFlatMap() {
		runAsyncTest{ array, collector in
			let values = await array.concurrentFlatMap{
				await collector.collectAndDuplicate($0)
			}
			
			XCTAssertEqual(values, array.flatMap{ [$0, $0] })
		}
	}
	
	func testThrowingConcurrentFlatMapThatDoesNotThrow() {
		runAsyncTest{ array, collector in
			let values = try await array.concurrentFlatMap{
				try await collector.tryCollectAndDuplicate($0)
			}
			
			XCTAssertEqual(values, array.flatMap{ [$0, $0] })
		}
	}
	
	func testThrowingConcurrentFlatMapThatThrows() {
		runAsyncTest{ array, collector in
			await self.verifyErrorThrown{ error in
				try await array.concurrentFlatMap{ int in
					try await collector.tryCollectAndDuplicate(
						int,
						throwError: int == 3 ? error : nil
					)
				}
			}
		}
	}
	
}
