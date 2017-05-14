get ()
{
    shini_get -s "$@"
    echo "$shini_value"
}

get Unit After
get Unit Description
get Service OOMScoreAdjust

# Only the last one is stored.
get Service Environment
