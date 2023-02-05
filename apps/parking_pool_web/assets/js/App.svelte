<script>
    // import {Socket} from "phoenix"
    import ParkingSpace from './ParkingSpace.svelte'
</script>

<div class="flex">
    <div class="w-full sm:w-auto">
        <div class="mt-10 grid grid-cols-1 gap-x-6 gap-y-4 sm:grid-cols-3">
            <ParkingSpace />
            <ParkingSpace />
        </div>
    </div>
</div>
<style>

</style>
