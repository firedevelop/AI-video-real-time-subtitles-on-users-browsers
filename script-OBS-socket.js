const { OBSWebSocket } = require('obs-websocket-js');
const obs = new OBSWebSocket();

async function stopRecordingAfter(seconds) {
  await obs.connect('ws://192.168.1.107:4455', '66CdLFiCHGEeLCtv');

  console.log(`Recording started. Will stop in ${seconds} seconds...`);

  let remaining = seconds;

  const intervalId = setInterval(() => {
    remaining--;
    if (remaining > 0) {
      console.log(`Time remaining: ${remaining} seconds`);
    }
  }, 1000);

  setTimeout(async () => {
    clearInterval(intervalId);
    await obs.call('StopRecord');
    console.log("Recording stopped!");
    process.exit();
  }, seconds * 1000);
}

stopRecordingAfter(5940);
