# Funktionalität

Dieses Paket enthält einen Invoker, der die Daten eines Config-Items versendet.

## Invoker ITSMConfigItemInvoker::Generic

Der Invoker `ITSMConfigItemInvoker::Generic` versendet die Daten eines Config-Items. Wird zusätzlich ein Event übergeben, werden auch die Daten einer ggf. vorhandenen Vorgängerversion übergeben. Das Event wird ausschließlich bei Konfiguration der Invoker-Details im Admin-Bereich `Web-Service-Verwaltung` für den Objekttyp ITSMConfigItem (`Kernel::GenericInterface::Event::ObjectType::ITSMConfigItem`) ausgelöst.

Folgende Events stehen zur Verfügung:

- ConfigItemCreate
- ConfigItemDelete
- DeploymentStateUpdate
- IncidentStateUpdate
- NameUpdate
- ValueUpdate
- VersionCreate

Bei den folgenden Events werden auch Daten der Vorgängerversion gesendet:

- DeploymentStateUpdate
- IncidentStateUpdate
- NameUpdate
- ValueUpdate
- VersionCreate

Bei den folgenden Events werden separat zu den Daten der Vorgängerversion noch die geänderten Werte in einem mit dem Event benannten Hash-Key gesendet:

- DeploymentStateUpdate
- IncidentStateUpdate
- NameUpdate
