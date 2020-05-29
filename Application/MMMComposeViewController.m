#import "MMMComposeViewController.h"
#import "UIColor+MeadowMail.h"
#import "UIFont+MeadowFont.h"

@implementation MMMComposeViewController

- (void)handleCancelButton {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleSendButton {
	UIAlertController *__block alert = [UIAlertController
		alertControllerWithTitle:@"Please wait"
		message:@"Sending your letter..."
		preferredStyle:UIAlertControllerStyleAlert
	];
	void(^showCompletionMessage)(NSString *, NSString *, BOOL) = ^(NSString *title, NSString *errorMessage, BOOL dismiss){
		[alert dismissViewControllerAnimated:YES completion:^{
			alert = [UIAlertController
				alertControllerWithTitle:title
				message:[NSString stringWithFormat:@"%@", errorMessage]
				preferredStyle:UIAlertControllerStyleAlert
			];
			[alert addAction:[UIAlertAction
				actionWithTitle:@"Dismiss"
				style:UIAlertActionStyleCancel
				handler:^(id action){
					if (dismiss) {
						NSString *message = [_messageTextView.text copy];
						NSString *title = [_titleTextField.text copy];
						[MMUserDefaults acquireLockWithCompletion:^{
							[MMUserDefaults objectForKey:@"mails" completion:^(NSArray *data){
								NSArray *mailArray = data;
								NSDictionary *newDict = @{
									@"content":message,
									@"date":[NSDate date],
									@"title":title,
									@"sent":@YES,
									@"starred":@NO
								};
								if (!mailArray) mailArray = @[newDict];
								else mailArray = [mailArray arrayByAddingObject:newDict];
								[MMUserDefaults setObject:mailArray forKey:@"mails" completion:^{
									[MMUserDefaults releaseLock];
								}];
							}];
						}];
						[self dismissViewControllerAnimated:YES completion:nil];
					}
				}
			]];
			[self presentViewController:alert animated:YES completion:nil];
		}];
	};
	[self presentViewController:alert animated:YES completion:^{
		NSDictionary *JSON = @{
			@"message" : _messageTextView.text,
			@"title" : _titleTextField.text
		};
		NSURL *URL = [NSURL URLWithString:@"https://api.pixelomer.com/meadow/v0/letter"];
		NSError *error = nil;
		NSData *HTTPBody = [NSJSONSerialization dataWithJSONObject:JSON options:0 error:&error];
		if (!HTTPBody) {
			showCompletionMessage(@"Error", error.description, NO);
			return;
		}
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
		request.HTTPMethod = @"POST";
		request.HTTPBody = HTTPBody;
		[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *HTTPError) {
			NSHTTPURLResponse *HTTPResponse = (id)response;
			NSError *error = nil;
			if (HTTPError || data.length < 0 || HTTPResponse.statusCode != 200) {
				showCompletionMessage(@"Error", error.description ?: @"The request failed.", NO);
				return;
			}
			NSDictionary *JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
			if (!JSONObject || error) {
				showCompletionMessage(@"Error", error.description ?: @"Could not parse the result.", NO);
				return;
			}
			else if (![JSONObject[@"success"] boolValue]) {
				showCompletionMessage(@"Error", JSONObject[@"error"] ?: @"An unknown error occurred.", NO);
				return;
			}
			showCompletionMessage(@"Success", @"Your letter has been successfully sent. Assuming that it doesn't contain anything inappropriate, a stranger will receive your letter soon.", YES);
		}];
	}];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	NSNumber *didComposeBefore = [[NSUserDefaults standardUserDefaults] objectForKey:@"didComposeBefore"];
	#if DEBUG
	[[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"didComposeBefore"];
	#else
	[[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"didComposeBefore"];
	#endif
	if (![didComposeBefore boolValue]) {
		UIAlertController *alert = [UIAlertController
			alertControllerWithTitle:@"Hello there!"
			message:@"This page lets you write short and positive letters for other MobileMeadow users in the world. This feature exists so that you can make another person's day a little better :)\n\n- Letters that are sent using this feature cannot be traced back to you in any way by anyone.\n- Before they are sent to someone else, letters will be reviewed by a moderator. If a moderator thinks a letter contains inappropriate content, it will be deleted and it won't be sent to anyone.\n- Letters must not contain any personal information that can be used to learn exactly who you are. Information such as your country or your nickname is probably fine. The moderators will make the final decision."
			preferredStyle:UIAlertControllerStyleAlert
		];
		[alert addAction:[UIAlertAction
			actionWithTitle:@"Dismiss"
			style:UIAlertActionStyleCancel
			handler:nil
		]];
		[self presentViewController:alert animated:YES completion:nil];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor meadow_systemBackgroundColor];
	[self.view addSubview:_separatorView];
	[self.view addSubview:_titleTextField];
	[self.view addSubview:_messageTextView];
	[self.view addConstraints:@[
		[NSLayoutConstraint
			constraintWithItem:_titleTextField
			attribute:NSLayoutAttributeTop
			relatedBy:NSLayoutRelationEqual
			toItem:self.topLayoutGuide
			attribute:NSLayoutAttributeBottom
			multiplier:1.0
			constant:10.0
		],
		[NSLayoutConstraint
			constraintWithItem:_titleTextField
			attribute:NSLayoutAttributeLeft
			relatedBy:NSLayoutRelationEqual
			toItem:self.view
			attribute:NSLayoutAttributeLeft
			multiplier:1.0
			constant:10.0
		],
		[NSLayoutConstraint
			constraintWithItem:_titleTextField
			attribute:NSLayoutAttributeRight
			relatedBy:NSLayoutRelationEqual
			toItem:self.view
			attribute:NSLayoutAttributeRight
			multiplier:1.0
			constant:-10.0
		],
		[NSLayoutConstraint
			constraintWithItem:_separatorView
			attribute:NSLayoutAttributeTop
			relatedBy:NSLayoutRelationEqual
			toItem:_titleTextField
			attribute:NSLayoutAttributeBottom
			multiplier:1.0
			constant:10.0
		],
		[NSLayoutConstraint
			constraintWithItem:_separatorView
			attribute:NSLayoutAttributeHeight
			relatedBy:NSLayoutRelationEqual
			toItem:nil
			attribute:NSLayoutAttributeNotAnAttribute
			multiplier:0.0
			constant:1.0
		],
		[NSLayoutConstraint
			constraintWithItem:_separatorView
			attribute:NSLayoutAttributeLeft
			relatedBy:NSLayoutRelationEqual
			toItem:self.view
			attribute:NSLayoutAttributeLeft
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:_separatorView
			attribute:NSLayoutAttributeRight
			relatedBy:NSLayoutRelationEqual
			toItem:self.view
			attribute:NSLayoutAttributeRight
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:_titleTextField
			attribute:NSLayoutAttributeHeight
			relatedBy:NSLayoutRelationGreaterThanOrEqual
			toItem:nil
			attribute:NSLayoutAttributeNotAnAttribute
			multiplier:0.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:_messageTextView
			attribute:NSLayoutAttributeTop
			relatedBy:NSLayoutRelationEqual
			toItem:_separatorView
			attribute:NSLayoutAttributeBottom
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:_messageTextView
			attribute:NSLayoutAttributeBottom
			relatedBy:NSLayoutRelationEqual
			toItem:self.bottomLayoutGuide
			attribute:NSLayoutAttributeTop
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:_messageTextView
			attribute:NSLayoutAttributeLeft
			relatedBy:NSLayoutRelationEqual
			toItem:self.view
			attribute:NSLayoutAttributeLeft
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:_messageTextView
			attribute:NSLayoutAttributeRight
			relatedBy:NSLayoutRelationEqual
			toItem:self.view
			attribute:NSLayoutAttributeRight
			multiplier:1.0
			constant:0.0
		]
	]];
}

- (instancetype)init {
	if ((self = [super init])) {
		self.title = @"New letter";
		_separatorView = [UIView new];
		_separatorView.backgroundColor = [UIColor lightGrayColor];
		_separatorView.translatesAutoresizingMaskIntoConstraints = NO;
		_titleTextField = [UITextField new];
		_titleTextField.placeholder = @"Title";
		_titleTextField.translatesAutoresizingMaskIntoConstraints = NO;
		_messageTextView = [UITextView new];
		_messageTextView.translatesAutoresizingMaskIntoConstraints = NO;
		_messageTextView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mail_background_tile"]];
		_messageTextView.contentInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
		_messageTextView.font = [UIFont meadow_mailFont];
		[_messageTextView setValue:@YES forKey:@"meadow_verticalOnly"];
		_messageTextView.alwaysBounceVertical = YES;
		_messageTextView.text = @"Hello, stranger! ...";
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
			initWithTitle:@"Send"
			style:UIBarButtonItemStyleDone
			target:self
			action:@selector(handleSendButton)
		];
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
			initWithTitle:@"Cancel"
			style:UIBarButtonItemStylePlain
			target:self
			action:@selector(handleCancelButton)
		];
	}
	return self;
}

@end