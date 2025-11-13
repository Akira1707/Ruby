import Data.List (intercalate)

-- Memoization factorial
factorials :: [Integer]
factorials = 1 : zipWith (*) [1..] factorials

factorial :: Integer -> Integer
factorial n = factorials !! fromIntegral n

-- Memoization Fibonacci
fibs :: [Integer]
fibs = 0 : 1 : zipWith (+) fibs (tail fibs)

fibonacci :: Integer -> Integer
fibonacci n = fibs !! fromIntegral n

-- Convert a result tuple to JSON string with indentation
toJSON :: (Integer, Integer, Integer) -> String
toJSON (n, f, fb) =
  "    {\n" ++
  "        \"number\": " ++ show n ++ ",\n" ++
  "        \"factorial\": " ++ show f ++ ",\n" ++
  "        \"fibonacci\": " ++ show fb ++ "\n" ++
  "    }"

main :: IO ()
main = do
  putStrLn "Enter numbers separated by spaces:"
  line <- getLine
  let nums = map read (words line) :: [Integer]
      results = map (\n -> (n, factorial n, fibonacci n)) nums
      jsonList = map toJSON results
      jsonStr = "[\n" ++ intercalate ",\n" jsonList ++ "\n]"
  putStrLn "\nComputation complete. JSON output:\n"
  putStrLn jsonStr
