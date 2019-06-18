-- Minetest has pos_to_string, but I believe that floor rounds the vector and adds bracket around it
function yatm_core.vector_to_string(vec)
  return vec.x .. "," .. vec.y .. "," .. vec.z
end
