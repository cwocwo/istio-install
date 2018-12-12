# Records are separated by blank lines.
# Each line is one field.
BEGIN { RS = "" ; FS = "\n" }

{
      if ($2=="jetstack") print $1"/"$2"/""cert-manager-controller:"$3; else print $1"/"$2"/"$2":"$3
}
