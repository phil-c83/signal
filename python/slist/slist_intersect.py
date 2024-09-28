# def slist_intersect(l1,l2):
#     def inter_rec(l1,l2,lr):    
#         if l1 == [] or l2 == [] :
#             return lr
#         elif l1[0] == l2[0]:        
#             inter_rec(l1[1:],l2[1:],[l1[0]] + lr)            
#         elif l1[0] > l2[0]:
#             inter_rec(l1,l2[1:],lr)
#         else: 
#             inter_rec(l1[1:],l2,lr)

#     return inter_rec(l1,l2,[])
def slist_intersect(l1,l2):
    lr=[]
    j=0
    k=0
    while j<len(l1) and k<len(l2):
        if l1[j] == l2[k]:
            lr = lr + [l1[j]]
            j += 1
            k += 1
        elif l1[j] > l2[k]:
            k += 1
        else : 
            j += 1
    return lr

def slist_diff(l1,l2):
    # l1 \ l2
    lr=[]
    j=0
    k=0
    while j<len(l1) and k<len(l2):
        if l1[j] == l2[k]:            
            j += 1
            k += 1
        elif l1[j] > l2[k]:
            k += 1
        else:
            lr = lr +[l1[j]]
            j += 1
    return lr 
    
            
print(slist_intersect([1,2,5,10,10,10,12,15],[2,2,5,10,10,15]))
print(slist_diff([1,2,5,10,10,10,12,15],[2,2,5,10,10,15]))
 