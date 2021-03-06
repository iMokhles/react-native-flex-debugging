//
//  IMLEXShortcutsSection.h
//  IMLEX
//
//  Created by Tanner Bennett on 8/29/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXTableViewSection.h"
#import "IMLEXObjectInfoSection.h"
@class IMLEXProperty, IMLEXIvar, IMLEXMethod;

/// An abstract base class for custom object "shortcuts" where every
/// row can possibly have some action. The section title is "Shortcuts".
///
/// You should only subclass this class if you need simple shortcuts
/// with plain titles and/or subtitles. This class will automatically
/// configure each cell appropriately. Since this is intended as a
/// static section, subclasses should only need to implement the
/// \c viewControllerToPushForRow: and/or \c didSelectRowAction: methods.
///
/// If you create the section using \c forObject:rows:numberOfLines:
/// then it will provide a view controller from \c viewControllerToPushForRow:
/// automatically for rows that are a property/ivar/method.
@interface IMLEXShortcutsSection : IMLEXTableViewSection <IMLEXObjectInfoSection>

/// Uses \c kIMLEXDefaultCell
+ (instancetype)forObject:(id)objectOrClass rowTitles:(NSArray<NSString *> *)titles;
/// Uses \c kIMLEXDetailCell for non-empty subtitles, otherwise uses \c kIMLEXDefaultCell
+ (instancetype)forObject:(id)objectOrClass
                rowTitles:(NSArray<NSString *> *)titles
             rowSubtitles:(NSArray<NSString *> *)subtitles;

/// Uses \c kIMLEXDefaultCell for rows that are given a title, otherwise
/// this uses \c kIMLEXDetailCell for any other allowed object.
///
/// The section provide a view controller from \c viewControllerToPushForRow:
/// automatically for rows that are a property/ivar/method.
///
/// @param rows A mixed array containing any of the following:
/// - any \c IMLEXShortcut conforming object
/// - an \c NSString
/// - a \c IMLEXProperty
/// - a \c IMLEXIvar
/// - a \c IMLEXMethodBase (includes \c IMLEXMethod of course)
/// Passing one of the latter 3 will provide a shortcut to that property/ivar/method.
/// @return \c nil if no rows are provided
+ (instancetype)forObject:(id)objectOrClass rows:(NSArray *)rows;

/// Same as \c forObject:rows: but the given rows are prepended
/// to the shortcuts already registered for the object's class.
/// \c forObject:rows: does not use the registered shortcuts at all.
+ (instancetype)forObject:(id)objectOrClass additionalRows:(NSArray *)rows;

/// Calls into \c forObject:rows: using the registered shortcuts for the object's class.
/// @return \c nil if the object has no shortcuts registered at all
+ (instancetype)forObject:(id)objectOrClass;

/// Subclasses \e may override this to hide the disclosure indicator
/// for some rows. It is shown for all rows by default, unless
/// you initialize it with \c forObject:rowTitles:rowSubtitles:
- (UITableViewCellAccessoryType)accessoryTypeForRow:(NSInteger)row;

/// The number of lines for the title and subtitle labels. Defaults to 1.
@property (nonatomic, readonly) NSInteger numberOfLines;
/// The object used to initialize this section.
@property (nonatomic, readonly) id object;

/// Whether dynamic subtitles should always be computed as a cell is configured.
/// Defaults to NO. Has no effect on static subtitles that are passed explicitly.
@property (nonatomic) BOOL cacheSubtitles;

@end

@class IMLEXShortcutsFactory;
typedef IMLEXShortcutsFactory *(^IMLEXShortcutsFactoryNames)(NSArray *names);
typedef void (^IMLEXShortcutsFactoryTarget)(Class targetClass);

/// The block properties below are to be used like SnapKit or Masonry.
/// \c IMLEXShortcutsSection.append.properties(@[@"frame",@"bounds"]).forClass(UIView.class);
///
/// To safely register your own classes at launch, subclass this class,
/// override \c +load, and call the appropriate methods on \c self
@interface IMLEXShortcutsFactory : NSObject

/// Returns the list of all registered shortcuts for the given object in this order:
/// Properties, ivars, methods.
///
/// This method traverses up the object's class hierarchy until it finds
/// something registered. This allows you to show different shortcuts for
/// the same object in different parts of the class hierarchy.
///
/// As an example, UIView may have a -layer shortcut registered. But if
/// you're inspecting a UIControl, you may not care about the layer or other
/// UIView-specific things; you might rather see the target-actions registered
/// for this control, and so you would register that property or ivar to UIControl,
/// And you would still be able to see the UIView-registered shorcuts by clicking
/// on the UIView "lens" at the top the explorer view controller screen.
+ (NSArray *)shortcutsForObjectOrClass:(id)objectOrClass;

@property (nonatomic, readonly, class) IMLEXShortcutsFactory *append;
@property (nonatomic, readonly, class) IMLEXShortcutsFactory *prepend;
@property (nonatomic, readonly, class) IMLEXShortcutsFactory *replace;

@property (nonatomic, readonly) IMLEXShortcutsFactoryNames properties;
/// Do not try to set \c classProperties at the same time as \c ivars or other instance things.
@property (nonatomic, readonly) IMLEXShortcutsFactoryNames classProperties;
@property (nonatomic, readonly) IMLEXShortcutsFactoryNames ivars;
@property (nonatomic, readonly) IMLEXShortcutsFactoryNames methods;
/// Do not try to set \c classMethods at the same time as \c ivars or other instance things.
@property (nonatomic, readonly) IMLEXShortcutsFactoryNames classMethods;

/// Accepts the target class. If you pass a regular class object,
/// shortcuts will appear on instances. If you pass a metaclass object,
/// shortcuts will appear when exploring a class object.
///
/// For example, some class method shortcuts are added to the NSObject meta
/// class by default so that you can see +alloc and +new when exploring
/// a class object. If you wanted these to show up when exploring
/// instances you would pass them to the classMethods method above.
@property (nonatomic, readonly) IMLEXShortcutsFactoryTarget forClass;

@end
