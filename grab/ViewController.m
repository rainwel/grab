//
//  ViewController.m
//  grab
//
//  Created by yiliao6 on 4/11/14.
//  Copyright (c) 2014 yiliao6. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  allSQL = @"\n";
  allDept = @"\n";
  allLink = @"\n";
  CGRect winFrame = [[UIScreen mainScreen] bounds];

  UITextView *tvUrl = [[UITextView alloc]
      initWithFrame:CGRectMake(20, 40, winFrame.size.width - 20 * 2, 40)];
  tvUrl.text = @"http://patient.weiyi.guahao.cn/app/rest/guide/triage.json";
  tvUrl.editable = NO;
  [self.view addSubview:tvUrl];

  UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [btn setTitle:@"Grab!" forState:UIControlStateNormal];
  btn.frame = CGRectMake(20, winFrame.size.height - 60, 80, 40);
  btn.backgroundColor = [UIColor clearColor];
  [btn addTarget:self
                action:@selector(clickBtn)
      forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:btn];

  UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [btn2 setTitle:@"Print!" forState:UIControlStateNormal];
  btn2.frame = CGRectMake(200, winFrame.size.height - 60, 80, 40);
  btn2.backgroundColor = [UIColor clearColor];
  [btn2 addTarget:self
                action:@selector(clickBtn2)
      forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:btn2];

  UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [btn3 setTitle:@"Test!" forState:UIControlStateNormal];
  btn3.frame = CGRectMake(200, winFrame.size.height - 100, 80, 40);
  btn3.backgroundColor = [UIColor clearColor];
  [btn3 addTarget:self
                action:@selector(clickBtn3)
      forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:btn3];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)clickBtn3 {
  NSString *uid = @"df966f20-0970-11e3-9a89-848f69fd6b70";
  [self getChooseDiagnose:uid bSelected:YES];
  [self getChooseDiagnose:uid bSelected:NO];
}

- (void)clickBtn2 {
  NSLog(@"allDept - %@", allDept);
  NSLog(@"\n");
  NSLog(@"allDept - %@", allLink);
  NSLog(@"\n");
  NSLog(@"allSQL - %@", allSQL);
}

- (void)clickBtn {
  [self getTriage];
}

- (void)getTriage {

  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  manager.requestSerializer = [AFJSONRequestSerializer serializer];
  manager.responseSerializer = [AFJSONResponseSerializer serializer];
  [manager.requestSerializer setValue:@"2.15" forHTTPHeaderField:@"version"];
  [manager POST:@"http://patient.weiyi.guahao.cn/app/rest/guide/triage.json"
      parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {

          NSDictionary *dict = (NSDictionary *)responseObject;

          NSArray *arrPart = (NSArray *)[dict objectForKey:@"partList"];

          for (int k = 0; k < arrPart.count; k++) {
            NSDictionary *item = (NSDictionary *)[arrPart objectAtIndex:k];
            NSInteger pId = [[item objectForKey:@"partId"] integerValue];
            NSString *pName = [item objectForKey:@"partName"];
            NSString *curSql = [NSString
                stringWithFormat:
                    @"insert into " @"ky_guides(guid,gname,gsource,gtype) "
                    @"values(\"%d\",\"%@\",\"weiyi\",\"triage\"); \n",
                    (int)pId, pName];

            [self getSymptoms:(int)pId];
            //            allSQL = [allSQL stringByAppendingString:curSql];
          }

      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"Error: %@", error);
      }];
}

- (void)getSymptoms:(int)pId {

  // Make a request...
  NSMutableURLRequest *request = [NSMutableURLRequest
      requestWithURL:[NSURL URLWithString:@"http://patient.weiyi.guahao.cn/app/"
                            @"rest/guide/symptoms.json"]];

  NSString *strData =
      [NSString stringWithFormat:@"{\"gender\":1,\"partId\":\"%d\"}", pId];
  // Generate an NSData from your NSString (see below for link to more info)
  NSData *postBody = [strData dataUsingEncoding:NSASCIIStringEncoding];

  // Add Content-Length header if your server needs it
  unsigned long long postLength = postBody.length;
  NSString *contentLength = [NSString stringWithFormat:@"%llu", postLength];
  [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];

  [request setValue:@"2.15" forHTTPHeaderField:@"version"];
  [request setValue:@"android" forHTTPHeaderField:@"User-Agent"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setValue:@"test" forHTTPHeaderField:@"hospital"];
  [request setValue:@"cTqXT8cpqqbWbT1enr/"
           @"e41dGtf1utweqJFuIR9UjqlH3VGT9r3Rtzfkqo5pcDUga7YIVey/"
           @"0jP+ZffQjhM2xkgbNl+KQxjyEGZP+" @"4kYugq2lGFcWMkDoKLAOsVcpz3xv+"
           @"Iz6MdRjG4h2Uhi2RaeZSNKV6VKH59kB1/QEZKf9v8I="
      forHTTPHeaderField:@"sign"];

  // This should all look familiar...
  [request setHTTPMethod:@"POST"];
  [request setHTTPBody:postBody];

  AFHTTPRequestOperation *operation =
      [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,
                                             id responseObject) {
      NSDictionary *dict = (NSDictionary *)responseObject;

      NSArray *arrPart = (NSArray *)[dict objectForKey:@"symptomItemList"];

      for (int k = 0; k < arrPart.count; k++) {
        NSDictionary *item = (NSDictionary *)[arrPart objectAtIndex:k];
        NSString *symptomUuid = [item objectForKey:@"symptomUuid"];
        NSString *symptomName = [item objectForKey:@"symptomName"];
        NSString *symptomContent = [item objectForKey:@"symptomContent"];
        NSString *curSQL = [NSString
            stringWithFormat:@"insert into "
                             @"ky_guides(guid,gpuid,gname,gnote,gsource,gtype) "
                             @"values(\"%@\",\"%d\",\"%@\",\"%@\",\"weiyi\","
                             @"\"symptoms\"); \n",
                             symptomUuid, pId, symptomName, symptomContent];
        [self getDiagnose:symptomUuid];
        //        allSQL = [allSQL stringByAppendingString:curSQL];
      }

  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      NSLog(@"pid - %d \n%@", pId, error);
  }];
  [operation start];
}

- (void)getDiagnose:(NSString *)pId {

  // Make a request...
  NSMutableURLRequest *request = [NSMutableURLRequest
      requestWithURL:[NSURL URLWithString:@"http://patient.weiyi.guahao.cn/app/"
                            @"rest/guide/diagnose.json"]];

  NSString *strData =
      [NSString stringWithFormat:@"{\"symptomUuid\":\"%@\"}", pId];
  // Generate an NSData from your NSString (see below for link to more info)
  NSData *postBody = [strData dataUsingEncoding:NSASCIIStringEncoding];

  // Add Content-Length header if your server needs it
  unsigned long long postLength = postBody.length;
  NSString *contentLength = [NSString stringWithFormat:@"%llu", postLength];
  [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];

  [request setValue:@"2.15" forHTTPHeaderField:@"version"];
  [request setValue:@"android" forHTTPHeaderField:@"User-Agent"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setValue:@"test" forHTTPHeaderField:@"hospital"];
  [request setValue:@"TzSGprUQgIZ8lXnzU2VJOa6cZZ2VpB+sBYL+"
           @"7Kj0SJVMqQSUAvo4BOtfJTJ31I4TpYpWk6XTY6uPL2Z/kph3K6zhKi/"
           @"WWD3MNkK7GwMwuyVNaiUjhRUCQpEG3wyhBS36bLY3jwgeX9RenT4wx9+"
           @"uUP7FRSJftYX34nDt6mTOqlM="
      forHTTPHeaderField:@"sign"];

  // This should all look familiar...
  [request setHTTPMethod:@"POST"];
  [request setHTTPBody:postBody];

  AFHTTPRequestOperation *operation =
      [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,
                                             id responseObject) {
      NSDictionary *dict = (NSDictionary *)responseObject;
      //      NSLog(@"dict - %@", dict);
      NSDictionary *item = (NSDictionary *)[dict objectForKey:@"diagnoseItem"];

      NSString *diagnoseUuid = [item objectForKey:@"diagnoseUuid"];
      NSString *diagnoseContent = [item objectForKey:@"diagnoseContent"];

      NSInteger level = [[item objectForKey:@"level"] integerValue];
      NSInteger isEnd = [[item objectForKey:@"isEnd"] integerValue];
      NSString *curSql = [NSString
          stringWithFormat:
              @"insert into "
              @"ky_guides(guid,gpuid,gname,glevel,gsource,gtype,gselect) "
              @"values(\"%@\",\"%@\",\"%@\",%d,\"weiyi\",\"diagnose\",1); \n",
              diagnoseUuid, pId, diagnoseContent, (int)level];

      allSQL = [allSQL stringByAppendingString:curSql];
      if (isEnd == 0 && [diagnoseUuid length] > 0) {
        [self getChooseDiagnose:diagnoseUuid bSelected:YES];
        [self getChooseDiagnose:diagnoseUuid bSelected:NO];
      }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      NSLog(@"pid - %@ \n%@", pId, error);
  }];
  [operation start];
}

- (void)getChooseDiagnose:(NSString *)pId bSelected:(BOOL)bSelected {

  // Make a request...
  NSMutableURLRequest *request = [NSMutableURLRequest
      requestWithURL:[NSURL URLWithString:@"http://patient.weiyi.guahao.cn/app/"
                            @"rest/guide/chooseDiagnose.json"]];

  NSString *strData = [NSString
      stringWithFormat:@"{\"isSelect\":\"%d\",\"diagnoseUuid\":\"%@\"}",
                       bSelected, pId];

  NSData *postBody = [strData dataUsingEncoding:NSASCIIStringEncoding];

  // Add Content-Length header if your server needs it
  unsigned long long postLength = postBody.length;
  NSString *contentLength = [NSString stringWithFormat:@"%llu", postLength];
  [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];

  [request setValue:@"2.15" forHTTPHeaderField:@"version"];
  [request setValue:@"android" forHTTPHeaderField:@"User-Agent"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setValue:@"test" forHTTPHeaderField:@"hospital"];
  [request setValue:@"B0V8Q/nVIXwQUqRvGmRSdo2ZS5FF3qS924CXue8mPFLcBo4qIh/"
           @"B8czjza3W9xJqY0d83jzDQrhtZMQj6IzZXiJllR2yOoo9BXQCbodrcxm"
           @"F96NTrAm9YVlteudt5SiT3XdIdd4jyGWGKnqOxG2Twpi5DIoF1MMUxPb"
           @"A9aIapi8="
      forHTTPHeaderField:@"sign"];

  // This should all look familiar...
  [request setHTTPMethod:@"POST"];
  [request setHTTPBody:postBody];

  AFHTTPRequestOperation *operation =
      [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,
                                             id responseObject) {
      NSDictionary *dict = (NSDictionary *)responseObject;
      NSDictionary *item = (NSDictionary *)[dict objectForKey:@"diagnoseItem"];
      NSString *diagnoseUuid = [item objectForKey:@"diagnoseUuid"];
      NSString *diagnoseContent = [item objectForKey:@"diagnoseContent"];
      NSArray *deptList = (NSArray *)[item objectForKey:@"deptInfoItemList"];
      for (int k = 0; k < deptList.count; k++) {
        NSDictionary *deptItem = (NSDictionary *)[deptList objectAtIndex:k];
        NSString *strDept = [NSString
            stringWithFormat:@"insert into ky_guides_dept(gdDeptId,gdDeptName) "
                             @"values(\"%@\",\"%@\");\n",
                             [deptItem objectForKey:@"deptId"],
                             [deptItem objectForKey:@"deptName"]];
        allDept = [allDept stringByAppendingString:strDept];
      }
      NSLog(@"getChooseDiagnose pid - %@ ; %d; \n%@; \n%@", pId, bSelected,
            diagnoseContent, dict);
      NSInteger level = [[item objectForKey:@"level"] integerValue];
      NSInteger isEnd = [[item objectForKey:@"isEnd"] integerValue];
      NSString *curSql = [NSString
          stringWithFormat:
              @"insert into "
              @"ky_guides(guid,gpuid,gname,glevel,gsource,gtype,gselect) "
              @"values(\"%@\",\"%@\",\"%@\",%d,\"weiyi\",\"diagnose\", %i); \n",
              diagnoseUuid, pId, diagnoseContent, (int)level, bSelected];

      //      NSLog(@" getChooseDiagnose pid - %@; isEnd - %d \n%@", pId,
      //      (int)isEnd,
      //            curSql);
      allSQL = [allSQL stringByAppendingString:curSql];
      if (isEnd == 0 && [diagnoseUuid length] > 0 && deptList.count == 0) {
        [self getChooseDiagnose:diagnoseUuid bSelected:YES];
        [self getChooseDiagnose:diagnoseUuid bSelected:NO];
      } else if (isEnd == 1 && [diagnoseUuid length] > 0) {
        for (int k = 0; k < deptList.count; k++) {
          NSDictionary *deptItem = (NSDictionary *)[deptList objectAtIndex:k];
          NSString *strDept = [NSString
              stringWithFormat:
                  @"insert into ky_guides_link(gnDiagnoseId,gnDeptId) "
                  @"values(\"%@\",\"%@\");\n",
                  diagnoseUuid, [deptItem objectForKey:@"deptId"]];
          allLink = [allLink stringByAppendingString:strDept];
        }
      }

  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      NSLog(@"pid - %@ \n%@", pId, error);
  }];
  [operation start];
}

@end
