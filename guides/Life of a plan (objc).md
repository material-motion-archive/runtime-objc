# Life of a plan: Objective-C

The first step to describing motion declaratively is to define your plans.

Let's say we want to describe a view as "draggable".

## Step 1: Define the plan

First, we create a new file pair called Draggable.h/m.

In Draggable.h:

    @import MaterialMotionRuntime;

    @interface Draggable : NSObject <MDMPlan>
    @end

In Draggable.m:

    @implementation Draggable
    @end

## Step 2: Define the performer

We now define the performer object that will fulfill our Draggable plan.

We map the plan to the performer by implementing the `performerClass` method on the plan.

In Draggable.m:

    @interface DraggablePerformer : NSObject <MDMPerforming>
    @end

    @implementation Draggable

    - (Class)performerClass {
      return [DraggablePerformer class];
    }

    @end

    @implementation DraggablePerformer
    @end

## Step 3: Implement the performer

We start by implementing the required `initWithTarget:` initializer from MDMPerforming. In this
initializer we register a pan gesture recognizer with the view.

> In practice we'll usually want to provide the gesture recognizer to the performer via the plan.
> This allows the creator of the plan to also pick which view the gesture recognizer is attached to.

In Draggable.m:

    @implementation DraggablePerformer

    - (instancetype)initWithTarget:(UIView *)target {
      self = [super init];
      if (self) {
        UIPanGestureRecognizer *pan = [UIPanGestureRecognizer new];
        [pan addTarget:self action:@selector(gestureDidChange:)];
        [target addGestureRecognizer:pan];
      }
      return self;
    }

    @end

We also implement the `gestureDidChange:` method. This method will be called whenever the user
interacts with the target view.

Note: The implementation shown below is only one of many ways such a performer could be implemented.

In Draggable.m:

    @interface DraggablePerformer ()
    @property(nonatomic) CGPoint initialGestureLocation;
    @property(nonatomic) CGPoint initialTargetPosition;
    @end

    - (void)gestureDidChange:(UIGestureRecognizer *)gesture {
      switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
          self.initialGestureLocation = [gesture locationInView:gesture.view.superview];
          self.initialTargetPosition = gesture.view.layer.position;
          break;

        case UIGestureRecognizerStateChanged: {
          CGPoint currentLocation = [gesture locationInView:gesture.view.superview];
          CGVector delta = CGVectorMake(currentLocation.x - self.initialGestureLocation.x,
                                        currentLocation.y - self.initialGestureLocation.y);
          CGPoint newPosition = CGPointMake(self.initialTargetPosition.x + delta.dx,
                                            self.initialTargetPosition.y + delta.dy);
          gesture.view.layer.position = newPosition;
          break;
        }

        default:
          break;
      }
    }

## Step 4: Associate plans with views

Create and retain a reference to a scheduler, likely in your view controller:

    self.scheduler = [MDMScheduler new];

Create a transaction. Plans are added to transactions. Transactions are committed to schedulers.

    MDMTransaction *transaction = [MDMTransaction new];
    [transaction addPlan:[Draggable new] toTarget:view];

Commit the transaction to the scheduler.

    [self.scheduler commitTransaction:transaction];

## Step 5: Test it!

You can now drag your view around.
