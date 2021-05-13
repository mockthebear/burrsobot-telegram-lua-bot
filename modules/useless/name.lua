function sugested() --Gerador de nomes

   local rare = {'k','y','x','q'}
   local cons = {'b','c','d','f','g','h','i','l','m','n','p','r','s','t','v','j'}
   local combined = {'vr', 'ck', 'tr', 'br', 'sh', 'th', 'pr', 'dr', 'fr', 'gr', 'cr', 'vr', 'nr', 'mr', 'nm', 'qu'}
   local vog = {"a",'e','i','o','u'}
   local sibalas = {}
   local sibalas3 = {}
   for i=1, #rare do 
   		if math.random(0,1000) >= 600 then
   			cons[#cons] = rare[i]
   		end
   end

   for i=1,#cons do
      for e=1,#vog do
        table.insert(sibalas,1,cons[i]..vog[e])
      end
   end

   for i=1,#combined do
      for e=1,#vog do
        table.insert(sibalas3,1,combined[i]..vog[e])
      end
   end

   local total = ""
   for i=1,math.random(1,2) do
       local nam = ""
       for i=1,math.random(2,4) do
       		if math.random(0,1000) >= 200 then
           		nam = nam..sibalas[math.random(1,#sibalas)]
           	else 
           		nam = nam..sibalas3[math.random(1,#sibalas3)]
           	end
       end
       if math.random(0,100) <= 40 then
          nam = nam..vog[math.random(1,#vog)]
       elseif math.random(0,100) <= 40 then
          nam = nam..cons[math.random(1,#vog)]
       end
       total = total..(i == 2 and ' ' or '')..nam:sub(1,1):upper()..nam:sub(2,-1)
   end
   return total
end


function OnCommand(user, msg, args)
    local names = ""
    for i=1,10 do
        names = names .. sugested() .. "\n"
    end
    say(tr("Gerado 10 nomes:\n")..names)
end