var PCM = (function(){
    var PCM_CHUNK_SIZE = 16,
        LINEAR_QUANTIZATION = 1,
        ushort = function(sample) {
            return String.fromCharCode(255 & sample,
                                       255 & sample >> 8);
        },
        ulong = function(sample) {
            return String.fromCharCode(255 & sample,
                                       255 & sample >> 8,
                                       255 & sample >> 16,
                                       255 & sample >> 24);
        },
        merge = function(defaults, extensions) {
            var merged = {};
            for (var name in defaults) {
                merged[name] = extensions.hasOwnProperty(name)
                    ? extensions[name]
                    : defaults[name];
            }
            return merged;
        },
        encode = function(data, opts) {
            opts = merge({
                channels: 1,
                bitdepth: 16,
                samplerate: 44100
            }, opts || {});
            var fmtChunk = [
                ["f", "m", "t", " "].join(""),
                ulong(PCM_CHUNK_SIZE),
                ushort(LINEAR_QUANTIZATION),
                ushort(opts.channels),
                ulong(opts.samplerate),
                ulong(opts.samplerate * opts.channels * opts.bitdepth / 8),
                ushort(opts.bitdepth / 8),
                ushort(opts.bitdepth)
            ].join("");
            var dataChunk = [
                ["d", "a", "t", "a"].join(""),
                ulong(data.length * opts.channels * opts.bitdepth / 8),
                data
            ].join("");
            var header = [
                ["R", "I", "F", "F"].join(""),
                ulong(4 + (8 + fmtChunk.length) + (8 + dataChunk.length)),
                ["W", "A", "V", "E"].join("")
            ].join("");
            return [header, fmtChunk, dataChunk].join("");
        },
        decode = function() {
            throw Error("Not implemented");
        },
        play = function(data, opts) {
            var audio = document.createElement("audio");
            audio.src = "data:audio/wav;base64," + btoa(encode(data, opts));
            audio.play();
        };
    return { encode: encode, decode: decode, play: play };
})();
