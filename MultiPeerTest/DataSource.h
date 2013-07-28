//Terry Lewis
//  JSDataSource.h
//  
//

#import <Foundation/Foundation.h>

typedef void (^CellConfigureBlock)(id cell, id item, id indexPath);

@interface DataSource : NSObject <UITableViewDataSource, UICollectionViewDataSource>
/**
 * A datasource class that can serve as both a UITableView and UICollectionView datasource.
 *\param items the array that will serve as the datasource.
 *\param identifier the cell identifier.
 *\param block the configuration block that is used to configure the cell, contains the cell, the item for the indexPath from the array and the indexPath.
 *\returns an instance of the class that will serve as a datasource for either a UITableView or UICollectionView.
*/
- (instancetype)initWithItems:(NSArray *)items cellIdentifier:(NSString *)identifier configureCellBlock:(CellConfigureBlock)block;
@property(nonatomic, strong) NSArray *items;


@end
