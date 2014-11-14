#!/usr/bin/env perl
# $Author: $Format:%an <%ae>$ $Format:%an <%ae>$ $
# $Date: $Format:%ai$ $Format:%ai$ $
# $Revision: $Format:%h$ $Format:%h$ $

while (<>) {
#s/\$Id[^\$]*\$/\$Id\$/; 
s/\$Date: $Format:%ai$ $]*\$/\$Date: \$Format:%ai\$ \$/;
s/\$Author: $Format:%an <%ae>$ $]*\$/\$Author: \$Format:%an <%ae>\$ \$/; 
#s/\$Source[^\$]*\$/\$Source\$/; 
#s/\$File[^\$]*\$/\$File\$/; 
s/\$Revision: $Format:%h$ $]*\$/\$Revision: \$Format:%h\$ \$/;
} continue {
print;
}

#s/\$Date: $Format:%ai$ $]*\$/\$Date\$/;
#s/\$Author: $Format:%an <%ae>$ $]*\$/\$Author\$/; 
#s/\$Revision: $Format:%h$ $]*\$/\$Revision\$/;

