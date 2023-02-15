<script>
    import { onMount } from 'svelte';

    import socket from "./socket.js"
    import ParkingSpace from './ParkingSpace.svelte'

    onMount(async () => {
        const res = await fetch(`/api/spaces`);
        spaces = await res.json();
    });

    socket.onError((e) => {
        // Token expired?
        console.error('Error connecting to socket', e)
        socketError = true;
    });
    socket.onOpen(() => {
        socketError = false;
    })

    let socketError = false;
    let spaces = []
</script>

<div class="flex">
    <div class="w-auto">
            <span class="block my-1 px-1 py-1 text-zinc-800 font-light text-xs rounded-lg"
                  class:invisible={!socketError}
            >
                connecting...
            </span>
            <div class="mt-2 sm:mt-10 grid grid-cols-3 gap-x-6 gap-y-4 auto-rows-[10rem]">
                {#each spaces as {id}, idx}
                    <ParkingSpace socket={socket} id={id} number={idx+1}/>
                {/each}
            </div>
    </div>
</div>
<style>

</style>
