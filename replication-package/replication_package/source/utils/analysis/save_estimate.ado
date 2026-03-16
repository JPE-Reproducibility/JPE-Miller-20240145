capture program drop save_estimate
program define save_estimate
    version 16.0
    syntax, key(string) value(string) file(string)

    local filepath "source/numbers/`file'.json"

    capture mkdir source
    capture mkdir source/numbers

    file open fh using "`filepath'", write append text
    file write fh "`key' = `value'" _n
    file close fh

    display "Saved to `filepath': `key' = `value'"
end
