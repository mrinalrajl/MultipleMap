import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
import coremltools as ct
import random

def generate_synthetic_data(num_samples=5000):
    data = []
    for _ in range(num_samples):
        # Features
        distance = random.uniform(1000, 50000) # 1km to 50km
        expected_time = (distance / random.uniform(10, 30)) + random.uniform(0, 600) # Seconds
        num_turns = random.randint(1, int(distance / 500) + 2)
        time_of_day = random.uniform(0, 24) # 0 to 24 hours
        
        # Calculate a hypothetical "Route Score" (higher is better)
        # We penalize long times and lots of turns, reward shorter distances.
        # This simulates a user preference.
        
        # Normalize roughly
        norm_dist = distance / 50000.0
        norm_time = expected_time / 3600.0
        norm_turns = num_turns / 50.0
        
        # Let's say the user really hates turns and long travel times.
        # Score out of 10.
        base_score = 10.0
        
        time_penalty = norm_time * 5.0
        turn_penalty = norm_turns * 3.0
        dist_penalty = norm_dist * 2.0
        
        score = base_score - time_penalty - turn_penalty - dist_penalty
        
        # Add some noise
        score += random.uniform(-0.5, 0.5)
        
        # Clamp between 0 and 10
        score = max(0.0, min(10.0, score))
        
        data.append({
            'distance': distance,
            'expectedTime': expected_time,
            'numberOfTurns': float(num_turns),
            'timeOfDay': time_of_day,
            'score': score
        })
        
    return pd.DataFrame(data)

def main():
    print("Generating synthetic route data...")
    df = generate_synthetic_data()
    
    X = df[['distance', 'expectedTime', 'numberOfTurns', 'timeOfDay']]
    y = df['score']
    
    print("Training RandomForestRegressor model...")
    # CoreML scikit-learn converter supports RandomForestRegressor
    model = RandomForestRegressor(n_estimators=50, max_depth=10, random_state=42)
    model.fit(X, y)
    
    print("Converting model to CoreML format...")
    # Convert using coremltools
    coreml_model = ct.converters.sklearn.convert(model, 
                                                 ['distance', 'expectedTime', 'numberOfTurns', 'timeOfDay'],
                                                 'routeScore')
    
    # Set metadata
    coreml_model.author = 'NaviSync AI'
    coreml_model.license = 'Proprietary'
    coreml_model.short_description = 'Predicts a route score (0-10) based on distance, time, and turns.'
    
    # Save the model
    model_path = 'RouteScorer.mlpackage'
    coreml_model.save(model_path)
    print(f"Model saved to {model_path}")

if __name__ == '__main__':
    main()
