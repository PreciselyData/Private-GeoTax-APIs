{{/*
Expand the name of the chart.
*/}}
{{- define "geotax-hook.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "geotax-hook.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "geotax-hook.labels" -}}
helm.sh/chart: {{ include "geotax-hook.chart" . }}
{{ include "geotax-hook.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "geotax-hook.selectorLabels" -}}
app.kubernetes.io/name: {{ include "geotax-hook.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}