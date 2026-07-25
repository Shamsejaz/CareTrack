import { supabase } from './supabase';

/**
 * Common Logic Layer (formerly API Gateway)
 * This service provides high-level business logic that coordinates multiple 
 * Supabase operations or external AI processing.
 */
export const CommonService = {
    /**
     * Analyzes a health log entry for potential medical alerts.
     */
    async analyzeHealthLog(logId: string, logType: string, value: string) {
        let interventionAlert = null;
        
        if (logType === 'Sugar') {
            const sugarValue = parseFloat(value);
            if (sugarValue > 180) {
                interventionAlert = { 
                    severity: 'High', 
                    message: 'Alert: High Sugar detected. Please hydrate and consult your medication schedule.' 
                };
            } else if (sugarValue < 70) {
                interventionAlert = { 
                    severity: 'Danger', 
                    message: 'Alert: Low Sugar detected! Please consume 15g of fast-acting carbs immediately.' 
                };
            }
        }

        // If an alert is detected, we could also log it to the notifications table here
        if (interventionAlert) {
            // Fetch the log to get the patient_id
            const { data: log } = await supabase.from('health_logs').select('patient_id').eq('id', logId).single();
            if (log) {
                await supabase.from('notifications').insert({
                    patient_id: log.patient_id,
                    type: interventionAlert.severity === 'Danger' ? 'critical_sugar' : 'high_sugar',
                    message: interventionAlert.message,
                });
            }
        }

        return { success: true, interventionAlert };
    },

    /**
     * Simulates prescription OCR and interaction checking.
     */
    async processPrescription(patientId: string, _imageUrl: string) {
        // In a real app, this would call an AI vision model
        // For now, we simulate the results
        const detectedMeds = [
            { name: 'Metformin', dose: '500mg', timing: 'After Breakfast', frequency: 'Daily' },
            { name: 'Lisinopril', dose: '10mg', timing: 'Morning', frequency: 'Daily' },
            { name: 'Atorvastatin', dose: '20mg', timing: 'Before Bed', frequency: 'Nightly' },
        ];

        // Save to database
        const medsToInsert = detectedMeds.map(m => ({ ...m, patient_id: patientId }));
        const { data, error } = await supabase.from('medications').insert(medsToInsert).select();

        return { success: !error, medications: data, error };
    }
};
