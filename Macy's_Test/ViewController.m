//
//  ViewController.m
//  Macy's_Test
//
//  Created by XIAOYAN ZHAO on 2/15/17.
//  Copyright © 2017 Shawn. All rights reserved.
//


#import "ViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

@interface ViewController (){
    _Bool flagBegin;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *jsonResult;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    flagBegin =false;//current no search happens.
    [_tableView setHidden:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


#pragma -mark UITableViewDelegate Method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.jsonResult.count == 0)// when no result or no begin search, use 1 cell to show "Sorry, no result found :(" or nothing.
        return 1;
    else
        return (self.jsonResult.count);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (self.jsonResult.count == 0)
    {
        if (!flagBegin){
            cell.textLabel.text = @"";//when no begin search, show nothing at cell.
        }
        else{
            cell.textLabel.text = @"Sorry, no result found :(";//when no search results.
        }
    }
    else{
        cell.textLabel.text = self.jsonResult[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];// used to dismiss keyboard.
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;// work together with Next Delegate Method to set auto height of Cell.
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

#pragma -mark SearchBar FetchData

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Loading Data...";//set MBProgressHUD begin animating.
    
    NSString *string = [NSString stringWithFormat:@"%@%@",ROOT_PATH,self.searchBar.text];
    
    
    [self AFNetworkingFetchData:string]; //Fetch Data using AFNetworking.
}

-(void)AFNetworkingFetchData:(NSString *) urlString{ //Fetching Data Method
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSURL *url = [NSURL URLWithString:urlString];
    // NSLog(@"%@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            
            flagBegin = true; // set flagBegin, since search already begin.
            id resultData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
            [self saveFetchDataIntoArrayResult:resultData];//save data into property _arrayResult locally.
            dispatch_async(dispatch_get_main_queue(),^{ //update the UI at main_queue
                [self.searchBar resignFirstResponder];
                [MBProgressHUD hideHUDForView:self.view animated:YES]; //Fetching finished, so hide MBProgressHUD animating.
                [_tableView setHidden:NO];
                [self.tableView reloadData]; // reload the UITableView at main_queue.
            });
        }
    }];
    [dataTask resume];
}

-(void)saveFetchDataIntoArrayResult:(id)resultData{ //storing data in jsonResult.
    NSArray *midArray = [resultData valueForKeyPath:@"lfs.lf"];
    if (midArray.count == 0) {
        self.jsonResult = nil;
    } else {
        self.jsonResult = [NSMutableArray arrayWithArray:midArray[0]];
    }
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar  // called when text ends editing
{
    [searchBar resignFirstResponder];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{//click Cancel-> clear searchBar text,clear _arrayResult,resignFirstResponder, dismiss the keyboard, then reload UITableView
    searchBar.text = @"";
    self.jsonResult = nil;
    flagBegin = false;
    [self.searchBar resignFirstResponder];
    [self.tableView reloadData];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchText.length==0) // when no search text, set like Cancel.
    {
        self.searchBar.text = @"";
        self.jsonResult = nil;
        flagBegin = false;
        [_tableView setHidden:YES];
        [self.tableView reloadData];
    }
}

@end
