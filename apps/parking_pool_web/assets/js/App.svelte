<script>
    import socket from "./socket.js"
    import ParkingSpace from './ParkingSpace.svelte'
</script>

<div class="flex">
    <div class="w-full sm:w-auto">
        <div class="mt-10 grid grid-cols-1 gap-x-6 gap-y-4 sm:grid-cols-3">
            <ParkingSpace socket={socket} id={'parking_space_1'}/>
            <ParkingSpace socket={socket} id={'parking_space_2'}/>
            <ParkingSpace socket={socket} id={'parking_space_3'}/>
        </div>
    </div>
</div>
<style>

</style>
