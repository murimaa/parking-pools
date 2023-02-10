<script>
    import { onMount } from 'svelte';

    import socket from "./socket.js"
    import ParkingSpace from './ParkingSpace.svelte'

    onMount(async () => {
        const res = await fetch(`/api/spaces`);
        spaces = await res.json();
    });
    let spaces = []
</script>

<div class="flex">
    <div class="w-auto">
        <div class="mt-10 grid grid-cols-3 gap-x-6 gap-y-4">
            {#each spaces as {id}}
                <ParkingSpace socket={socket} id={id}/>
            {/each}
        </div>
    </div>
</div>
<style>

</style>
