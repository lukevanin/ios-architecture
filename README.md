#  ClearScore iOS Developer Assessment

**Luke Van In**


# 1. Architecture

The application uses a variant of the VIPER architecture, and is comprised of the following 
categories of components:

1. Views: Displays information to the user. Receives input from the user. Uses presenters. 
2. Presenters: Implements presentation logic. Transforms data to a form that is application to
the human user, and transforms human interactions and input into machine data. Uses 
interactors. Used by Views.
3. Interactors: Implements business domain logic. Transforms raw data into business models.
Implements business rules (constraints, conditions, outcomes). Uses repositories. Used by
presenters.
4. Entities: Models business domain data. May also implement business rules and constraints.
5. Repositories: Provides raw data from external or internal resources. These typically model
databases or web service endpoints. For this example, the repository is an abstraction of the 
credit score data, with the actual data being provided by a service component. 
6. Services: Raw access to web service endpoints. These can also provide abstractions over 
system services such as geo-location, photo library, and push notifications.

This example makes use other components that are not part of the traditional VIPER 
architecture patterns:

1. Modules / Module builders: Module builders construct views and their associated 
dependencies including presenters, wireframes, and interactors. Their dependencies include
system wide components and frameworks, such as databases, analytics, and localisations.
2. Wireframes (aka Coordinators): Instantiates views, and navigation. Used by
presenters. Uses module builders to instantiate views.
3. Services: Encapsulates external resources, such as backend endpoints. These can 
often be auto-generated using tooling such as OpenAPI, and ProtoBufs. 

This separation of concerns lends itself to testing by defining clear boundaries for 
responsibilities in a way that is generally applicable, and allows components to be tested in
isolation thereby reducing ambiguity and inconsistencites in tests.

## Views

Views display information to the user, and recieve input from the user. Views are kept as simple
as possible with almost all logic being implemented in presenters. This separation allows logic
to be tested in code, and without having to resort to more complicted UI tests. 

For this example, everything in UIKit is considered to be within the scope of the view layer. 

In my design, presenters pass view models to views. It is the responsibility of the view to map 
the view model to the display outputs. In traditional VIPER architecture, the presenter would 
normally call property setters on views to set attributes. Passing a view model shifts some 
responsiblity to the view layer, but also has benefits such as:

* Atomicity in view updates, which has benefits such as avoiding artefacts due to incomplete 
or inconsistent view updates.
* Simplified tests, in that the test can inspect the view model.

The views are:

* `CreditScoreViewController`: Displays the credit score value, maximum, and guage.

I also implented the following ancilliary view components:

* `GaugeView`: Displays a circular progress bar with a conical gradient fill. Used to display the
user's credit score.
* `GaugeViewController`: Used to test the GaugeView in an isloated environment during 
development. A slider can be used to manipulate the gauge manually. 

## Presenters

Presenters have two responsibilities:

* Transform business models into view models, which are passed by views to be present 
information to the user. 
* Transform user inputs into the business model domain.

In this example, the `CreditScorePresenterImplementation` retrieves data from the
interactor, transforms th data into a view model, and notifies the observer (view). The presenter 
responds to actions from the view, such as a button press to refresh the data. The design of 
the interface allows the implementation of the presenter to change independently of the view. 
For example, the presenter could preiodically refresh data and push updates to the view 
automatically, without requiring any changes to be made to the view.

VIPER usually defines separate interfaces for the presenter input and output. In this example, 
the view attaches an observer closer to the presenter to receive updates. This facilitates 
testing, by allowing tests to assign simple closures, instead of having to implement 
complicated mock objects.

## Wireframes / Coordinators

Wireframes are used by presenters to perform actions such as navigation, presenting alerts, or
other side effects that manipulate the view hierarchy. Encapsulating this behaviour into an 
object that is separate to the presenter and view has some benefits, including:

* Facilitates testing: Wireframes can be optional or mocked, to allow core presenter logic to
be tested in isolation.
* Flexible navigation: Application navigation can be changed without affecting the view or 
presenter by changing only the wireframe. Different wireframes can be used for different 
platforms, e.g. Master/Detail on iPad, and UINavigationController on iPhone.

For this example, I only implemented a mock wireframe to facilitate testing, but did not 
implement a wireframe for the demo application. A wireframe can be easily added to the credit
score module, to display error messages using a `UIAlertViewController`, or other 
notification mechanism such as a toast. 

## Entities

Entities include data objects that model the business domain. These can be simple objects, or
databases.

The entities used in this example are:

* `CreditScore`: Models credit score data received from the backend endpoint.
* `Localisations`: Simple localisation model used to provide text strings, used for testing.

## Interactors

Interactors encapsulate business logic for interacting with domain models. Their purpose is
similar to Actions in a redux model, where they provide predictable, atomic modifications on
critical data. 

Interactors use repositories to access resources, and provide data to presenters.

For this example, the `CreditScoreRepositoryInteractor` primarily transforms the low
level repository data retrieved from the backend web servcie, into an application data model.

This allows the backend endpoints and application model to evolve and change independently
of each other, allowing the application model to be better adapted to the needs of the 
application. In practice, interactors may also implement more complicated business logic, such
as validating data, enforcing constraints, and ensuring data integrity, possibly in conjuction 
with an underlying database.

## Repositories

Repositories provide an interface for interacting with raw data, typically originating from 
external sources such as a web service, file, database, or system service. As repositories are
abstractions, they may also provide additional capabilities to facilitate data access, such as
caching data, or transforming data from a low level representation to a higher level model, or
established format.


# 2. Development process

This section provides a short overview of the process I went through to develop the example.
The progress can also be observed in the git commit history. 

In a general sense, I followed a 
bottom up development approach, starting with services, then repositories, then interactors,
and finally ending with the views. 

I predominantly followed a test driven approach, although I generally implemented code for 
each facet in the order of:

* Model objects (structs or classess)
* Abstract interfaces using the model objects
* Concrete implementations of abstract interfaces
* Unit tests

This process was repeated for each of the layers from services to views, mentioned above.


# 3. Exclusions

Some things I might have added, but were excluded in interests of time. I'm happy to address
questions or provide further examples on request if necessary.

## UI tests

The view components used by primary view controller use accessibility identifiers, which can 
be used to introspect the contents of the view from an `XCUITest`.

## Factories

The primary components are constructed in the `AppDelegate`. This should ideally be 
encapsulated by an abstract factory, which can construct shared components such as the 
`Localisations` model, and delegate to module builders to construct view components.

## Project structure

I used single files to contain various aspects of the application design. In a production 
application code base, each component type might be in a single file a separate folder instead 
of being combined together in one file. Depending on the scope and scale of the project, and 
the structure of the team, a more granular project structure may be beneficial. e.g. using 
separate targets for each sub-structure (sevices, repositories, domain logic, presenters), or 
even individual targets for separable components (one target per service, repository, domain 
model, and view module).

