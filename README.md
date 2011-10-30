Microphone

A Javascript wrapper around AS3 Microphone.

## Usage

    <script src="microphone.js">
        Microphone.ready(function() {
            Microphone.enable();
            Microphone.ondata(function(data) {
                console.log(data.length); // Typically 2048 bytes.
            });
        });
    </script>
