<script>
  import { m } from "@inlang/paraglide-js/messages";

  let name = "World";
</script>

<div>
  <h1>{m.hello_world()}</h1>
  <p>{m.greeting({ name })}</p>
  
  <div class="profile">
    <h2>{m["user.profile.title"]()}</h2>
    <button>{m["user.profile.edit"]()}</button>
  </div>

  <div class="actions">
    <button class="primary">{m.common.save()}</button>
    <button class="secondary">{m.common.cancel()}</button>
  </div>
</div>

<style>
  div {
    padding: 1rem;
  }
</style>
