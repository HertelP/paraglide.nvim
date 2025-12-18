import { m } from "@inlang/paraglide-js/messages";

// Simple message call
console.log(m.hello_world());

// Message with parameters
const username = "Alice";
console.log(m.greeting({ name: username }));

// In JSX
export function HomePage() {
    return (
        <div>
            <h1>{m.user.profile.title()}</h1>
            <p>{m.greeting({ name: "Bob" })}</p>
            <button>{m.common.save()}</button>
        </div>
    );
}

// With parameters
const appName = "MyApp";
console.log(m.welcome({ app: appName }));

// Nested in expressions
if (error) {
    throw new Error(m.error.not_found());
}
