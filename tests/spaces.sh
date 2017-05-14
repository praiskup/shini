get ()
{
    shini_get -s "$@"
    echo "$shini_value"
}

get "with  double space"  "aho  j"
get "with  double space"  ahoj
get "with  double space"  ahoj
get "a   b" a
